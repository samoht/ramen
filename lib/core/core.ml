(** Core types for the Ramen static site generator *)

module Site = Site
module Blog = Blog
module Author = Author
module Page = Page
module Static = Static
module Paper = Paper
module File = File
module Date = Date
module Pp = Pp

type t = {
  site : Site.t;
  blog_posts : Blog.t list;
  authors : Author.t list;
  static_pages : Static.t list;
  papers : Paper.t list;
  files : File.t list;
}
(** Combined website data *)

let pp t =
  Pp.record
    [
      ("site", Site.pp t.site);
      ("blog_posts", Pp.list Blog.pp t.blog_posts);
      ("authors", Pp.list Author.pp t.authors);
      ("static_pages", Pp.list Static.pp t.static_pages);
      ("papers", Pp.list Paper.pp t.papers);
      ("files", Pp.list File.pp t.files);
    ]
