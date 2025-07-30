(** This module provides the high-level interface for building static sites,
    serving as the main entry point for the `ramen build` command.

    Build acts as a coordinator that brings together all the components needed
    for static site generation:

    1. Loads data using the Data module 2. Validates the loaded content 3.
    Delegates to Engine for the actual generation 4. Reports errors in a
    user-friendly way

    This module represents the complete build pipeline for static mode, handling
    both success and error cases. It ensures that partial builds don't leave the
    output directory in an inconsistent state by validating everything before
    generation begins.

    The separation between Build and Engine allows for:
    - Clear error handling boundaries
    - Future support for different build strategies
    - Clean integration with the CLI layer

    While Engine handles the mechanics of generation, Build provides the policy
    and workflow. *)

val run :
  data_dir:string ->
  output_dir:string ->
  theme:string ->
  ?minify:bool ->
  unit ->
  (unit, [ `Msg of string ]) result
(** [run ~data_dir ~output_dir ~theme ?minify ()] builds the static site from
    the data directory to the output directory using the specified theme. *)
