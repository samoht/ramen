(** Tests for the Blog module *)

open Alcotest

let blog_testable = testable (Fmt.of_to_string Core.Blog.pp) ( = )
let author_testable = testable (Fmt.of_to_string Core.Author.pp) ( = )

let test_post_creation () =
  let author = Core.Blog.Name { name = "Test Author"; slug = "test-author" } in
  let post =
    {
      Core.Blog.authors = [ author ];
      title = "Test Post";
      image = "/images/test.jpg";
      image_alt = Some "Test image";
      date = "2024-01-01";
      slug = "test-post";
      tags = [ "test"; "ocaml" ];
      synopsis = "This is a test post";
      description = "A longer description of the test post";
      body_html = "<p>Test content</p>";
      body_words = [ "Test"; "content" ];
      path = "posts/test-post.md";
      link = None;
      links = [];
    }
  in

  check string "post title" "Test Post" post.title;
  check string "post slug" "test-post" post.slug;
  check (list string) "post tags" [ "test"; "ocaml" ] post.tags;
  check string "post date" "2024-01-01" post.date

let test_author_functions () =
  let team_author =
    {
      Core.Author.name = "Jane Doe";
      title = Some "Developer";
      hidden = false;
      avatar = None;
      slug = "jane-doe";
      aliases = [];
      homepage = None;
    }
  in
  let author : Core.Blog.author = Core.Blog.Author team_author in
  let name_author =
    Core.Blog.Name { name = "John Smith"; slug = "john-smith" }
  in

  check string "author name from Author" "Jane Doe"
    (Core.Blog.author_name author);
  check string "author slug from Author" "jane-doe"
    (Core.Blog.author_slug author);
  check string "author name from Name" "John Smith"
    (Core.Blog.author_name name_author);
  check string "author slug from Name" "john-smith"
    (Core.Blog.author_slug name_author);

  (* Test author_team function *)
  check author_testable "author_team" team_author (Core.Blog.author_team author)

let test_filter () =
  let tag_filter = Core.Blog.Tag "ocaml" in
  let author_filter =
    Core.Blog.Author (Core.Blog.Name { name = "Test"; slug = "test" })
  in

  let tag_pp = Core.Blog.pp_filter tag_filter in
  let author_pp = Core.Blog.pp_filter author_filter in

  check bool "tag filter pp" true
    (Astring.String.is_infix ~affix:"ocaml" tag_pp);
  check bool "author filter pp" true
    (Astring.String.is_infix ~affix:"Test" author_pp)

let test_index () =
  let posts = [] in
  let index =
    {
      Core.Blog.filter = Some (Core.Blog.Tag "test");
      page = 1;
      posts;
      all_posts = posts;
    }
  in

  check int "index page" 1 index.page;
  check (list blog_testable) "empty posts" [] index.posts;

  let pp_output = Core.Blog.pp_index index in
  check bool "pp contains filter" true
    (Astring.String.is_infix ~affix:"Tag" pp_output)

let test_filter_posts () =
  let post1 =
    {
      Core.Blog.authors =
        [ Core.Blog.Name { name = "Author1"; slug = "author1" } ];
      title = "OCaml Post";
      image = "test.jpg";
      image_alt = None;
      date = "2024-01-01";
      slug = "ocaml-post";
      tags = [ "ocaml"; "functional" ];
      synopsis = "About OCaml";
      description = "OCaml programming";
      body_html = "<p>OCaml</p>";
      body_words = [ "OCaml" ];
      path = "ocaml.md";
      link = None;
      links = [];
    }
  in
  let post2 =
    {
      post1 with
      title = "Python Post";
      slug = "python-post";
      tags = [ "python"; "scripting" ];
      authors = [ Core.Blog.Name { name = "Author2"; slug = "author2" } ];
    }
  in
  let posts = [ post1; post2 ] in

  (* Test tag filter *)
  let ocaml_posts =
    Core.Blog.filter_posts ~filter:(Core.Blog.Tag "ocaml") posts
  in
  check int "filtered by ocaml tag" 1 (List.length ocaml_posts);
  check string "correct post" "OCaml Post" (List.hd ocaml_posts).title;

  (* Test author filter *)
  let author1_posts =
    Core.Blog.filter_posts
      ~filter:
        (Core.Blog.Author
           (Core.Blog.Name { name = "Author1"; slug = "author1" }))
      posts
  in
  check int "filtered by author" 1 (List.length author1_posts)

let test_paginate () =
  let post i =
    {
      Core.Blog.authors = [ Core.Blog.Name { name = "Test"; slug = "test" } ];
      title = "Post " ^ string_of_int i;
      image = "test.jpg";
      image_alt = None;
      date = "2024-01-01";
      slug = "post-" ^ string_of_int i;
      tags = [];
      synopsis = "Test";
      description = "Test";
      body_html = "<p>Test</p>";
      body_words = [ "Test" ];
      path = "test.md";
      link = None;
      links = [];
    }
  in
  let posts = List.init 25 (fun i -> post (i + 1)) in

  (* Test pagination with 10 posts per page *)
  let page1 = Core.Blog.paginate ~posts_per_page:10 posts 1 in
  let page2 = Core.Blog.paginate ~posts_per_page:10 posts 2 in
  let page3 = Core.Blog.paginate ~posts_per_page:10 posts 3 in

  check int "page 1 count" 10 (List.length page1);
  check int "page 2 count" 10 (List.length page2);
  check int "page 3 count" 5 (List.length page3);

  check string "first post page 1" "Post 1" (List.hd page1).title;
  check string "first post page 2" "Post 11" (List.hd page2).title;
  check string "first post page 3" "Post 21" (List.hd page3).title

let test_url_of_index () =
  let index1 =
    { Core.Blog.filter = None; page = 1; posts = []; all_posts = [] }
  in
  let index2 = { index1 with page = 2 } in
  let index_tag = { index1 with filter = Some (Core.Blog.Tag "ocaml") } in
  let index_author =
    {
      index1 with
      filter =
        Some
          (Core.Blog.Author
             (Core.Blog.Name { name = "Test"; slug = "test-author" }));
      page = 3;
    }
  in

  check string "page 1 url" "/blog/" (Core.Blog.url_of_index index1);
  check string "page 2 url" "/blog/page/2/" (Core.Blog.url_of_index index2);
  check string "tag filter url" "/blog/tag/ocaml/"
    (Core.Blog.url_of_index index_tag);
  check string "author filter page 3" "/blog/author/test-author/page/3/"
    (Core.Blog.url_of_index index_author)

let test_all_tags () =
  let post1 =
    {
      Core.Blog.authors = [];
      title = "Post 1";
      image = "test.jpg";
      image_alt = None;
      date = "2024-01-01";
      slug = "post1";
      tags = [ "ocaml"; "web" ];
      synopsis = "Test 1";
      description = "Test post 1";
      body_html = "<p>Test 1</p>";
      body_words = [ "Test"; "1" ];
      path = "post1.md";
      link = None;
      links = [];
    }
  in
  let post2 =
    {
      Core.Blog.authors = [];
      title = "Post 2";
      image = "test.jpg";
      image_alt = None;
      date = "2024-01-02";
      slug = "post2";
      tags = [ "rust"; "web" ];
      synopsis = "Test 2";
      description = "Test post 2";
      body_html = "<p>Test 2</p>";
      body_words = [ "Test"; "2" ];
      path = "post2.md";
      link = None;
      links = [];
    }
  in

  let tags = Core.Blog.all_tags [ post1; post2 ] in
  check (list string) "unique sorted tags" [ "ocaml"; "rust"; "web" ] tags

let test_all_authors () =
  let author1 = Core.Blog.Name { name = "Author 1"; slug = "author1" } in
  let author2 = Core.Blog.Name { name = "Author 2"; slug = "author2" } in
  let post1 =
    {
      Core.Blog.authors = [ author1 ];
      title = "Post 1";
      image = "test.jpg";
      image_alt = None;
      date = "2024-01-01";
      slug = "post1";
      tags = [];
      synopsis = "Test 1";
      description = "Test post 1";
      body_html = "<p>Test 1</p>";
      body_words = [ "Test"; "1" ];
      path = "post1.md";
      link = None;
      links = [];
    }
  in
  let post2 =
    {
      Core.Blog.authors = [ author2; author1 ];
      title = "Post 2";
      image = "test.jpg";
      image_alt = None;
      date = "2024-01-02";
      slug = "post2";
      tags = [];
      synopsis = "Test 2";
      description = "Test post 2";
      body_html = "<p>Test 2</p>";
      body_words = [ "Test"; "2" ];
      path = "post2.md";
      link = None;
      links = [];
    }
  in

  let authors = Core.Blog.all_authors [ post1; post2 ] in
  check int "unique authors count" 2 (List.length authors)

let suite =
  [
    ( "blog",
      [
        test_case "post creation" `Quick test_post_creation;
        test_case "author functions" `Quick test_author_functions;
        test_case "filter" `Quick test_filter;
        test_case "index" `Quick test_index;
        test_case "filter posts" `Quick test_filter_posts;
        test_case "paginate" `Quick test_paginate;
        test_case "url of index" `Quick test_url_of_index;
        test_case "all tags" `Quick test_all_tags;
        test_case "all authors" `Quick test_all_authors;
      ] );
  ]
