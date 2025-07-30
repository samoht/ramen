(** Blog post types *)

type name = { name : string; slug : string }
type author = Author of Author.t | Name of name

type t = {
  authors : author list;
  title : string;
  image : string;
  image_alt : string option;
  date : string;
  slug : string;
  tags : string list;
  synopsis : string;
  description : string;
  body_html : string;
  body_words : string list;
  path : string;
  link : string option;
  links : string list;
}

type filter = Tag of string | Author of author

type index = {
  filter : filter option;
  page : int;
  posts : t list;
  all_posts : t list;
}

(** Utility functions *)

val date : t -> string
(** [date post] returns the raw date string of a post. *)

val pretty_date : t -> string
(** [pretty_date post] returns a pretty formatted date (e.g., "January 1,
    2024"). *)

val author_name : author -> string
(** [author_name author] returns the author's name. *)

val author_slug : author -> string
(** [author_slug author] returns the author's slug. *)

val author_team : author -> Author.t
(** [author_team author] converts author to team member. Raises [Failure] if
    author is Name. *)

val pp_name : name Pp.t
(** [pp_name name] pretty-prints a name. *)

val pp_author : author Pp.t
(** [pp_author author] pretty-prints an author. *)

val pp : t Pp.t
(** [pp t] pretty-prints a blog post. *)

val pp_filter : filter Pp.t
(** [pp_filter filter] pretty-prints a filter. *)

val pp_index : index Pp.t
(** [pp_index index] pretty-prints a blog index. *)

(** {2 Utility functions} *)

val filter_posts : ?filter:filter -> t list -> t list
(** [filter_posts ?filter posts] filters posts by tag or author. *)

val paginate : posts_per_page:int -> t list -> int -> t list
(** [paginate ~posts_per_page posts page] returns the posts for the given page
    number. *)

val url_of_index : index -> string
(** [url_of_index index] returns the URL for a blog index page. *)

val all_tags : t list -> string list
(** [all_tags posts] returns all unique tags from the given posts. *)

val all_authors : t list -> author list
(** [all_authors posts] returns all unique authors from the given posts. *)
