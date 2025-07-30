(** Tests for the Blog page module *)

open Alcotest
module P = Views
open Core
module Views = P

let make_test_post ~title ~slug ~date ~tags ~summary ~authors =
  {
    Blog.title;
    slug;
    authors;
    image = "";
    image_alt = None;
    date;
    tags;
    synopsis = summary;
    description = summary;
    body_html = "<p>" ^ summary ^ "</p>";
    body_words = Astring.String.cuts ~empty:false ~sep:" " summary;
    path = "/blog/" ^ slug;
    link = None;
    links = [];
  }

let make_test_author name : Blog.author =
  Name { slug = String.lowercase_ascii name; name }

let make_test_site ?(posts_per_page = 10) () =
  {
    Site.name = "Test Blog";
    url = "https://test.com";
    title = "Test Blog";
    tagline = "A test blog";
    description = "Test blog description";
    author = "Test Author";
    author_email = "test@test.com";
    social = None;
    analytics = None;
    footer = { copyright = "© Test"; links = [] };
    posts_per_page = Some posts_per_page;
  }

let test_render_basic () =
  let site = make_test_site () in

  let posts =
    [
      make_test_post ~title:"First Post" ~slug:"first-post" ~date:"2024-01-01"
        ~tags:[ "test"; "ocaml" ] ~summary:"First post summary"
        ~authors:[ make_test_author "Alice" ];
      make_test_post ~title:"Second Post" ~slug:"second-post" ~date:"2024-01-02"
        ~tags:[ "test" ] ~summary:"Second post summary"
        ~authors:[ make_test_author "Bob" ];
    ]
  in

  let all_tags = [ "test"; "ocaml"; "web" ] in

  let index = { Blog.posts; filter = None; page = 1; all_posts = posts } in

  let layout = Views.Blog.render ~site ~blog_posts:posts ~all_tags index in
  let config = { Ui.Layout.main_css = "/css/main.css"; js = [] } in
  let html = Ui.Layout.to_string config layout in

  check bool "contains first post title" true
    (Astring.String.is_infix ~affix:"First Post" html);
  check bool "contains second post title" true
    (Astring.String.is_infix ~affix:"Second Post" html);
  check bool "contains tag filter" true
    (Astring.String.is_infix ~affix:"ocaml" html)

let test_render_with_filter () =
  let site = make_test_site () in

  let alice = make_test_author "Alice" in
  let bob = make_test_author "Bob" in

  let posts =
    [
      make_test_post ~title:"Alice's Post" ~slug:"alice-post" ~date:"2024-01-01"
        ~tags:[ "test" ] ~summary:"Alice's post" ~authors:[ alice ];
      make_test_post ~title:"Bob's Post" ~slug:"bob-post" ~date:"2024-01-02"
        ~tags:[ "test" ] ~summary:"Bob's post" ~authors:[ bob ];
    ]
  in

  let all_tags = [ "test" ] in

  (* Filter by author Alice *)
  let filtered_posts = Blog.filter_posts ~filter:(Blog.Author alice) posts in

  let index =
    {
      Blog.posts = filtered_posts;
      filter = Some (Blog.Author alice);
      page = 1;
      all_posts = posts;
    }
  in

  let layout = Views.Blog.render ~site ~blog_posts:posts ~all_tags index in
  let config = { Ui.Layout.main_css = "/css/main.css"; js = [] } in
  let html = Ui.Layout.to_string config layout in

  (* HTML entities encode apostrophes as &apos; *)
  check bool "contains Alice's post" true
    (Astring.String.is_infix ~affix:"Alice&apos;s Post" html);
  check int "filtered posts count" 1 (List.length filtered_posts)

let test_render_pagination () =
  let site =
    {
      Site.name = "Test Blog";
      url = "https://test.com";
      title = "Test Blog";
      tagline = "A test blog";
      description = "Test blog description";
      author = "Test Author";
      author_email = "test@test.com";
      social = None;
      analytics = None;
      footer = { copyright = "© Test"; links = [] };
      posts_per_page = Some 2;
    }
  in

  let posts =
    List.init 5 (fun i ->
        make_test_post
          ~title:("Post " ^ string_of_int (i + 1))
          ~slug:("post-" ^ string_of_int (i + 1))
          ~date:("2024-01-0" ^ string_of_int (i + 1))
          ~tags:[ "test" ]
          ~summary:("Summary " ^ string_of_int (i + 1))
          ~authors:[ make_test_author "Author" ])
  in

  let all_tags = [ "test" ] in

  (* Page 2 should have posts 3 and 4 *)
  let paginated = Blog.paginate ~posts_per_page:2 posts 2 in

  let index =
    { Blog.posts = paginated; filter = None; page = 2; all_posts = posts }
  in

  let layout = Views.Blog.render ~site ~blog_posts:posts ~all_tags index in
  let config = { Ui.Layout.main_css = "/css/main.css"; js = [] } in
  let html = Ui.Layout.to_string config layout in

  check int "page 2 posts count" 2 (List.length paginated);
  check bool "contains post 3" true
    (Astring.String.is_infix ~affix:"Post 3" html);
  check bool "contains post 4" true
    (Astring.String.is_infix ~affix:"Post 4" html);
  check bool "has pagination controls" true
    (Astring.String.is_infix ~affix:"page" html)

let suite =
  [
    ( "blog",
      [
        test_case "render basic" `Quick test_render_basic;
        test_case "render with filter" `Quick test_render_with_filter;
        test_case "render with pagination" `Quick test_render_pagination;
      ] );
  ]
