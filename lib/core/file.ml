(** File types *)

type path = { url : string }

type target =
  | File of path
  | Responsive of { main : int * path; alternates : (path * int) list }

type t = { origin : string; target : target }

type url =
  | Url of string
  | Responsive of { src : string; srcset : string; sizes : string }

let pp_path path = Pp.quote path.url

let pp_target = function
  | File path -> Pp.str [ "File "; Pp.parens (pp_path path) ]
  | Responsive { main = width, path; alternates } ->
      let main_str = Pp.str [ Pp.int width; "px: "; pp_path path ] in
      let alt_str =
        Pp.list
          (fun (path, width) -> Pp.str [ Pp.int width; "px: "; pp_path path ])
          alternates
      in
      Pp.str
        [ "Responsive { main = "; main_str; "; alternates = "; alt_str; " }" ]

let pp t =
  Pp.record [ ("origin", Pp.quote t.origin); ("target", pp_target t.target) ]

(* Utility functions *)

let url_of_target = function
  | File f -> Url f.url
  | Responsive { alternates = r; _ } ->
      let sizes =
        "(min-width: 1360px) 1360px, (min-width: 680px) 680px, 100vw"
      in
      let srcset =
        List.map (fun (f, w) -> f.url ^ " " ^ string_of_int w ^ "w") r
      in
      let srcset = String.concat ", " srcset in
      let last, _ = List.hd (List.rev r) in
      Responsive { src = last.url; srcset; sizes }

let href t =
  match url_of_target t.target with Url s -> s | Responsive { src; _ } -> src
