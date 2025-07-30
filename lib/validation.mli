(** This module ensures data integrity by validating all content after loading
    but before use, serving as a critical safety layer in the architecture.

    Validation sits at the boundary between data loading and data usage,
    enforcing business rules that can't be expressed in the type system alone.
    While OCaml's types ensure structural correctness, this module ensures
    semantic correctness:

    - Email addresses are properly formatted
    - URLs are valid
    - Dates follow expected formats
    - Required relationships exist (e.g., all blog posts have valid authors)
    - Content meets minimum requirements

    Architecturally, Validation serves several purposes:

    1. **Early failure**: Catches errors before generation begins 2. **Clear
    error messages**: Provides file names and line numbers 3. **Centralized
    rules**: All validation logic in one place 4. **Type safety boundary**:
    Bridges untyped input to typed Core structures

    This module is used by the Data module after loading content, ensuring that
    by the time data reaches the Engine or Views, it has been thoroughly
    validated. This allows downstream modules to work with confidence, knowing
    the data meets all requirements. *)

type error = {
  file : string;
  line : int option;
  field : string option;
  message : string;
}
(** Validation error information *)

exception Validation_error of error
(** Exception raised for validation errors *)

val pp_error : Format.formatter -> error -> unit
(** [pp_error fmt error] pretty-prints a validation error. *)

val error : ?line:int -> file:string -> field:string -> string -> 'a
(** [error ?line ~file ~field message] creates a validation error. *)

val validate_email : ?line:int -> file:string -> field:string -> string -> unit
(** [validate_email ?line ~file ~field email] validates an email address. *)

val validate_url : ?line:int -> file:string -> field:string -> string -> unit
(** [validate_url ?line ~file ~field url] validates a URL. *)

val validate_date : ?line:int -> file:string -> field:string -> string -> unit
(** [validate_date ?line ~file ~field date] validates a date in YYYY-MM-DD
    format. *)

val validate_author : file:string -> Core.Author.t -> unit
(** [validate_author ~file author] validates a team member. *)

val validate_blog_post : file:string -> Core.Blog.t -> unit
(** [validate_blog_post ~file post] validates a blog post. *)

val validate_site_config : file:string -> Core.Site.t -> unit
(** [validate_site_config ~file site] validates site configuration. *)

val validate_static_page : file:string -> Core.Page.static -> unit
(** [validate_static_page ~file page] validates a static page. *)

val validate_paper : file:string -> Core.Paper.t -> unit
(** [validate_paper ~file paper] validates a paper. *)

val validate_all : Core.t -> (unit, error) result
(** [validate_all data] validates all loaded data. *)
