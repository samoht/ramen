open Html
open Tw

type opacity = Opacity_50 | Opacity_70
type size = Size_6 | Size_8 | Size_10 | Size_12 | Size_16

let size_to_int = function
  | Size_6 -> 6
  | Size_8 -> 8
  | Size_10 -> 10
  | Size_12 -> 12
  | Size_16 -> 16

let size_classes size =
  match size_to_int size with
  | 6 -> [ w (int 6); h (int 6) ]
  | 8 -> [ w (int 8); h (int 8) ]
  | 10 -> [ w (int 10); h (int 10) ]
  | 12 -> [ w (int 12); h (int 12) ]
  | 16 -> [ w (int 16); h (int 16) ]
  | _ -> [] (* Should never happen with variant types *)

let opacity_class = function
  | Opacity_50 -> opacity 50
  | Opacity_70 -> on_hover [ opacity 70 ]

let initials ?(size = Size_10) ?opacity name =
  let initials =
    Astring.String.cuts ~sep:" " ~empty:false name
    |> List.map String.capitalize_ascii
    |> List.filter (( <> ) "The")
    |> List.map (fun s -> String.make 1 s.[0])
    |> String.concat ""
  in
  let opacity_classes =
    match opacity with Some op -> [ opacity_class op ] | None -> []
  in
  div
    ~tw:
      (size_classes size
      @ [
          relative;
          inline_flex;
          items_center;
          justify_center;
          overflow_hidden;
          bg ~shade:100 gray;
          rounded full;
          dark (bg ~shade:600 gray);
        ]
      @ opacity_classes)
    [ span ~tw:[ font_medium; text ~shade:300 gray ] [ txt initials ] ]

type t = {
  size : size option;
  opacity : opacity option;
  ring : int option;
  author : Core.Author.t;
}
(** Component data for avatars *)

let render t =
  let size = Option.value t.size ~default:Size_10 in
  let opacity = t.opacity in
  let ring = t.ring in
  let author = t.author in
  match author.avatar with
  | None -> initials ~size ?opacity author.name
  | Some avatar ->
      let opacity_classes =
        match opacity with Some op -> [ opacity_class op ] | None -> []
      in
      let _ring_classes =
        match ring with
        | Some _width ->
            [ (* Ring classes temporarily removed from minimal API *) ]
        | None -> []
      in
      div
        ~tw:
          (size_classes size
          @ [ rounded full; bg ~shade:100 gray; overflow_hidden; m (int 1) ]
          @ opacity_classes)
        [
          img
            ~at:[ At.src avatar; At.alt author.name; At.loading_lazy ]
            ~tw:[ w full; h full; object_cover ]
            ();
        ]

let pp_size s = Core.Pp.str [ "Size_"; string_of_int (size_to_int s) ]

let pp_opacity = function
  | Opacity_50 -> Core.Pp.str [ "Opacity_50" ]
  | Opacity_70 -> Core.Pp.str [ "Opacity_70" ]

let pp t =
  Core.Pp.record
    [
      ("size", Core.Pp.option pp_size t.size);
      ("opacity", Core.Pp.option pp_opacity t.opacity);
      ("ring", Core.Pp.option Core.Pp.int t.ring);
      ("author", Core.Author.pp t.author);
    ]
