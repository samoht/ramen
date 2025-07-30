(** Blog posts module for loading and managing blog content *)

type name = Core.Blog.name [@@deriving show]
(** The type of a blog post name *)

type author = Core.Blog.author [@@deriving show]
(** The type of a blog post author *)

type t = Core.Blog.t [@@deriving show]
(** The type of a blog post *)

type index = Core.Blog.index [@@deriving show]

val load : dir:string -> (t list, string) result
(** [load ~dir] loads all blog posts from the given directory. Blog posts are
    expected to be markdown files with YAML frontmatter. *)
