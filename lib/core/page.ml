(** Page types *)

(* Use the Static module's type *)
type static = Static.t

(** Page variant for site navigation *)
type t =
  | Index
  | Blog_index of Blog.index
  | Blog_post of Blog.t
  | Blog_feed
  | Papers
  | Static_page of Static.t
  | Error
  | Sitemap
  | Robots_txt

(** Utility functions *)

let create_blog_index ?filter ?author ?tag page =
  let filter =
    match (filter, author, tag) with
    | Some f, _, _ -> Some f
    | None, Some a, _ -> Some (Blog.Author a)
    | None, None, Some t -> Some (Blog.Tag t)
    | None, None, None -> None
  in
  (* Note: The actual blog index data (posts) will be passed from outside *)
  Blog_index { filter; page; posts = []; all_posts = [] }

let url ?domain:(_ = false) = function
  | Index -> "/"
  | Blog_index { page; filter; _ } -> (
      let base =
        match filter with
        | None -> "/blog"
        | Some (Blog.Tag tag) -> "/blog/tag/" ^ tag
        | Some (Blog.Author author) -> "/blog/author/" ^ Blog.author_slug author
      in
      match page with 1 -> base | n -> base ^ "/page/" ^ string_of_int n)
  | Blog_post post -> "/blog/" ^ post.Blog.slug
  | Blog_feed -> "/blog/feed.xml"
  | Papers -> "/papers"
  | Static_page page -> "/" ^ page.name
  | Error -> "/404.html"
  | Sitemap -> "/sitemap.xml"
  | Robots_txt -> "/robots.txt"

let pp_static = Static.pp

let pp = function
  | Index -> "Index"
  | Blog_index idx -> Pp.str [ "Blog_index "; Pp.parens (Blog.pp_index idx) ]
  | Blog_post post -> Pp.str [ "Blog_post "; Pp.parens (Blog.pp post) ]
  | Blog_feed -> "Blog_feed"
  | Papers -> "Papers"
  | Static_page page -> Pp.str [ "Static_page "; Pp.parens (Static.pp page) ]
  | Error -> "Error"
  | Sitemap -> "Sitemap"
  | Robots_txt -> "Robots_txt"
