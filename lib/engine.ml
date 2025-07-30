(** Site generator engine *)

let ( / ) = Filename.concat

let mkdir path =
  match Bos.OS.Dir.create ~path:true (Fpath.v path) with
  | Ok _ -> ()
  | Error (`Msg err) -> Fmt.failwith "mkdir %s: %s" path err

let to_base64url string =
  Base64.encode_string ~pad:false ~alphabet:Base64.uri_safe_alphabet string

let main_css ~data_dir =
  let path = Fpath.(v data_dir / "css" / "main.css") in
  match Bos.OS.File.exists path with
  | Ok true ->
      let digest = to_base64url (Digest.file (Fpath.to_string path)) in
      Fmt.str "/css/main~%s.css" digest
  | _ -> "/css/main.css"

let copy_file src dst =
  match Bos.OS.File.read (Fpath.v src) with
  | Ok content -> (
      mkdir (Filename.dirname dst);
      match Bos.OS.File.write (Fpath.v dst) content with
      | Ok () -> ()
      | Error (`Msg err) -> Fmt.failwith "write %s: %s" dst err)
  | Error (`Msg err) -> Fmt.failwith "read %s: %s" src err

let copy_static_files ~data_dir ~output_dir (files : File.t list) =
  Fmt.pr "Copying static files...\n%!";
  List.iter
    (fun file ->
      let copy_img file =
        let src = data_dir ^ "/" ^ file.Core.File.origin in
        let dst =
          match file.Core.File.target with
          | Core.File.File f -> output_dir ^ f.url
          | Core.File.Responsive { main = _, f; _ } -> output_dir ^ f.url
        in
        Fmt.pr "Copying %a -> %a\n%!"
          Fmt.(styled (`Fg `Blue) string)
          src
          Fmt.(styled (`Fg `Green) string)
          dst;
        copy_file src dst
      in
      copy_img file;
      match file.Core.File.target with
      | Responsive { alternates; _ } ->
          (* For responsive images, we also need to copy alternates *)
          List.iter
            (fun (f, _) ->
              copy_img { Core.File.origin = file.origin; target = File f })
            alternates
      | _ -> ())
    files

(* Generate all blog index pages with pagination *)
let blog_index_pages ~posts_per_page ~filter posts =
  let rec paginate_pages page_num posts_remaining acc =
    match posts_remaining with
    | [] -> List.rev acc
    | _ ->
        let page_posts =
          posts_remaining |> List.to_seq |> Seq.take posts_per_page
          |> List.of_seq
        in
        let remaining =
          posts_remaining |> List.to_seq |> Seq.drop posts_per_page
          |> List.of_seq
        in
        let index =
          {
            Core.Blog.filter;
            page = page_num;
            posts = page_posts;
            all_posts = posts;
          }
        in
        paginate_pages (page_num + 1) remaining
          (Core.Page.Blog_index index :: acc)
  in
  paginate_pages 1 posts []

(* Generate filtered index pages for a specific filter *)
let generate_filtered_pages ~posts_per_page ~filter ~blog_posts =
  let filtered = Core.Blog.filter_posts ~filter blog_posts in
  blog_index_pages ~posts_per_page ~filter:(Some filter) filtered

(* Generate tag index pages *)
let generate_tag_pages ~posts_per_page ~blog_posts =
  Core.Blog.all_tags blog_posts
  |> List.map (fun tag ->
         let filter = Core.Blog.Tag tag in
         generate_filtered_pages ~posts_per_page ~filter ~blog_posts)
  |> List.flatten

(* Generate author index pages *)
let generate_author_pages ~posts_per_page ~blog_posts =
  Core.Blog.all_authors blog_posts
  |> List.map (fun author ->
         let filter = Core.Blog.Author author in
         generate_filtered_pages ~posts_per_page ~filter ~blog_posts)
  |> List.flatten

(* Generate all pages for the site *)
let generate_all_pages data =
  let posts_per_page =
    Option.value ~default:10 data.Core.site.Core.Site.posts_per_page
  in
  let blog_posts = data.blog_posts in

  (* Individual blog post pages *)
  let post_pages = List.map (fun p -> Core.Page.Blog_post p) blog_posts in

  (* Main blog index pages *)
  let main_index_pages =
    blog_index_pages ~posts_per_page ~filter:None blog_posts
  in

  (* Tag and author index pages *)
  let tag_pages = generate_tag_pages ~posts_per_page ~blog_posts in
  let author_pages = generate_author_pages ~posts_per_page ~blog_posts in

  (* Static pages *)
  let static_pages =
    List.map (fun p -> Core.Page.Static_page p) data.static_pages
  in

  (* System pages *)
  let system_pages =
    [
      Core.Page.Index;
      Core.Page.Blog_feed;
      Core.Page.Papers;
      Core.Page.Sitemap;
      Core.Page.Robots_txt;
    ]
  in

  system_pages @ post_pages @ main_index_pages @ tag_pages @ author_pages
  @ static_pages

(* Page rendering dispatch *)
let render_page ~data page =
  let site = data.Core.site in
  match page with
  | Core.Page.Index ->
      Views.Index.render ~site ~static_pages:data.static_pages
        ~blog_posts:data.blog_posts
  | Core.Page.Blog_index idx ->
      let all_tags = Core.Blog.all_tags data.blog_posts in
      Views.Blog.render ~site ~blog_posts:data.blog_posts ~all_tags idx
  | Core.Page.Blog_post post -> Views.Post.render ~site post
  | Core.Page.Blog_feed -> Views.Feed.render ~site ~blog_posts:data.blog_posts
  | Core.Page.Papers -> Views.Papers.render ~site ~papers:data.papers
  | Core.Page.Static_page _static ->
      (* TODO: Implement static page rendering *)
      Views.Not_found.render ~site
  | Core.Page.Error -> Views.Not_found.render ~site
  | Core.Page.Sitemap ->
      let pages = generate_all_pages data in
      Views.Sitemap.render ~site ~pages
  | Core.Page.Robots_txt -> Views.Robots.render ~site

let generate_html_and_collect_tw ~data_dir ~output_dir ~data =
  (* Generate HTML pages and collect tw styles *)
  let layout_config = { Ui.Layout.main_css = main_css ~data_dir; js = [] } in
  Fmt.pr "\nRendering HTML pages...\n%!";

  (* Render all pages and collect tw styles *)
  let all_tw_styles = ref [] in
  let pages = generate_all_pages data in

  List.iter
    (fun p ->
      let rendered = render_page ~data p in
      (* Collect tw styles from this page *)
      all_tw_styles := !all_tw_styles @ Ui.Layout.to_tw rendered;

      let str = Ui.Layout.to_string layout_config rendered in
      let path =
        match Core.Page.url p with
        | "/" -> output_dir / "index.html"
        | s when String.ends_with ~suffix:"/" s ->
            let path_without_leading_slash =
              if String.starts_with ~prefix:"/" s then
                String.sub s 1 (String.length s - 1)
              else s
            in
            (output_dir / path_without_leading_slash) ^ "index.html"
        | s -> output_dir ^ s
      in
      mkdir (Filename.dirname path);
      Fmt.pr "Rendering %a\n%!" Fmt.(styled (`Fg `Green) string) path;
      let oc = open_out path in
      output_string oc str;
      close_out oc)
    pages;

  !all_tw_styles

let generate ~data_dir ~output_dir ~minify ~data =
  let root = Unix.realpath output_dir in
  Fmt.pr "Root path: %s\n%!" root;

  (* Copy static files *)
  copy_static_files ~data_dir ~output_dir:root data.Core.files;

  (* Generate all HTML pages and collect tw styles *)
  let tw_styles =
    generate_html_and_collect_tw ~data_dir ~output_dir:root ~data
  in

  (* Generate CSS from collected Tailwind styles *)
  let stylesheet = Ui.Tw.of_tw tw_styles in
  let css_content = Ui.Css.to_string ~minify stylesheet in

  let css_path = root / "css" / "main.css" in
  let css_dir = Filename.dirname css_path in
  mkdir css_dir;

  let oc = open_out css_path in
  output_string oc css_content;
  close_out oc;
  Fmt.pr "Generated CSS -> %a\n%!" Fmt.(styled (`Fg `Green) string) css_path;

  Fmt.pr "\n✨ Site generated successfully!\n%!";
  Fmt.pr "To view the site locally, run:\n%!";
  Fmt.pr "  cd %s && python3 -m http.server 8080\n%!" output_dir;
  Fmt.pr "Then open http://localhost:8080/ in your browser.\n%!"
