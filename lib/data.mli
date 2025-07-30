(** This module bridges the pure functional core with the filesystem, loading
    content from disk into the type-safe Core.t data structures.

    The Data module is the primary entry point for loading site content in all
    three Ramen build modes:

    - Static mode: Loads data once at build time to generate static HTML files
    - Dynamic mode: Loads data on server startup and watches for changes
    - Crunched mode: Data is pre-compiled into OCaml modules (this module is
      bypassed)

    All data loading goes through this module, which: 1. Reads Markdown and YAML
    files from the data/ directory 2. Parses frontmatter and content 3. Converts
    everything into Core.t types 4. Validates data integrity via the Validation
    module

    This separation allows the Core module to remain pure while this module
    handles all the I/O operations needed to populate the data structures. *)

type t = Core.t
(** The data type *)

val show : t -> string
(** [show t] returns a string representation of the data. *)

val pp : Format.formatter -> t -> unit
(** [pp fmt t] pretty-prints the data. *)

type load_error = [ `Load of string | `Validation of Validation.error ]
(** Result type for loading operations *)

(** Data loading functionality *)

val load : data_dir:string -> (Core.t, [> `Load of string ]) result
(** [load ~data_dir] loads all data files from a directory. *)

val load_site : data_dir:string -> (Core.t, load_error) result
(** [load_site ~data_dir] loads and validates all site data from the given
    directory. *)
