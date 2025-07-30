(** Site configuration module for loading site settings *)

type link = Core.Site.link
(** The type of a navigation link *)

type footer = Core.Site.footer
(** The type of footer configuration *)

type social = Core.Site.social
(** The type of social media links *)

type analytics = Core.Site.analytics
(** The type of analytics configuration *)

type t = Core.Site.t
(** The type of site configuration *)

val of_file : dir:string -> (t, string) result
(** [of_file ~dir] loads the site configuration from the site.yml file in the
    given directory. *)

val pp : t Fmt.t
(** [pp t] pretty-prints site [t]. *)
