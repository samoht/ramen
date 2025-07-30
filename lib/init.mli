(** Project initialization logic *)

val create_project : project_name:string -> (Fpath.t, [ `Msg of string ]) result
(** [create_project ~project_name] creates a new Ramen project with the given
    name. Returns the path to the created project directory on success. *)
