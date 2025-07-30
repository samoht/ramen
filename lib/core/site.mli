(** Site configuration types *)

type link = { href : string; text : string }
type footer = { copyright : string; links : link list }

type social = {
  twitter : string option;
  github : string option;
  linkedin : string option;
}

type analytics = { google : string option; piwik : string option }

type t = {
  name : string;
  url : string;
  title : string;
  tagline : string;
  description : string;
  author : string;
  author_email : string;
  social : social option;
  analytics : analytics option;
  footer : footer;
  posts_per_page : int option; (* Number of posts per page for blog pagination *)
}

val pp : t Pp.t
(** [pp t] pretty-prints site data [t]. *)
