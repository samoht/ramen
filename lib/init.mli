(** Project initialization logic *)

val project : project_name:string -> (Fpath.t, [ `Msg of string ]) result
(** [project ~project_name] creates a new Ramen project with the given name.
    Returns the path to the created project directory on success. *)
