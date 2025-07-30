(** This module orchestrates the static site generation process, coordinating
    between data loading, view rendering, and file output.

    The Engine is responsible for the "build" phase in static mode, taking the
    loaded and validated data from the Data module and transforming it into a
    complete static website. It:

    1. Creates the output directory structure 2. Generates HTML pages using the
    Views modules 3. Processes and copies static assets 4. Implements
    cache-busting for CSS files 5. Ensures all necessary files are written to
    disk

    In the architecture, Engine sits between the pure Core/Views modules and the
    filesystem, handling all the I/O operations needed to produce the final
    static site. While Views modules create HTML structures, Engine writes them
    to disk.

    This module is primarily used in static build mode (`ramen build`). In
    dynamic serve mode, similar functionality is handled on-the-fly by the Serve
    module. *)

val main_css : data_dir:string -> string
(** [main_css ~data_dir] gets the path to the main CSS file with cache-busting
    hash. *)

val generate :
  data_dir:string -> output_dir:string -> minify:bool -> data:Core.t -> unit
(** [generate ~data_dir ~output_dir ~minify ~data] generates the complete static
    site. *)
