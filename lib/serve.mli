(** This module implements the dynamic serving mode, providing a development
    server with live reload capabilities.

    Serve represents the second major build mode in Ramen's architecture, where
    instead of generating static files, content is rendered on-demand. This
    mode:

    1. Loads data into memory at startup (like static mode) 2. Starts an HTTP
    server to handle requests 3. Renders pages dynamically when requested 4.
    Watches for file changes and reloads automatically 5. Provides instant
    feedback during development

    The architectural significance of Serve is that it reuses the same Core data
    structures and Views modules as static generation, but applies them
    differently:

    - Static mode: Data -> Engine -> Files on disk
    - Dynamic mode: Data -> Serve -> HTTP responses

    This demonstrates the flexibility of separating pure logic from I/O - the
    same view functions can generate files or serve HTTP responses without
    modification.

    While primarily intended for development, the dynamic mode can also be used
    in production scenarios where real-time updates are needed. *)

val run :
  data_dir:string ->
  output_dir:string ->
  theme:string ->
  port:int ->
  no_watch:bool ->
  (unit, [ `Msg of string ]) result
(** [run ~data_dir ~output_dir ~theme ~port ~no_watch] builds the site and
    starts a development server on the specified port. *)
