(** This module defines the pure, immutable data structures that form the heart
    of Ramen's architecture.

    Core is the central module in the lib/core/ directory, providing:

    1. **Type definitions**: All the data structures used throughout the system
    2. **Pure functions**: Operations on data with no side effects 3. **Business
    logic**: Core rules and transformations 4. **No I/O**: Completely free of
    file, network, or system operations

    The Core.t type is the primary data structure that flows through the entire
    system, containing all the content and configuration needed to generate a
    website. This design enables:

    - **Testability**: Pure data structures are easy to construct and test
    - **Portability**: Can be compiled to JavaScript via js_of_ocaml
    - **Clarity**: Clear data flow through the system
    - **Flexibility**: Same data can be used for static generation or dynamic
      serving

    In all three build modes (static, dynamic, crunched), Core.t serves as the
    common data representation. The only difference is how this data is loaded:
    - Static/Dynamic: Loaded from disk by the Data module
    - Crunched: Compiled directly into the binary

    This module re-exports all the sub-modules for convenience, making Core the
    single entry point for all pure data types and operations. *)

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

val pp : t Pp.t
(** [pp t] pretty-prints website data [t]. *)
