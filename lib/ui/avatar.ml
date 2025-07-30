open Html

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
  | 6 -> [ Tw.w_6; Tw.h_6 ]
  | 8 -> [ Tw.w_8; Tw.h_8 ]
  | 10 -> [ Tw.w_10; Tw.h_10 ]
  | 12 -> [ Tw.w_12; Tw.h_12 ]
  | 16 -> [ Tw.w_16; Tw.h_16 ]
  | _ -> [] (* Should never happen with variant types *)

let opacity_class = function
  | Opacity_50 -> Tw.opacity_50
  | Opacity_70 -> Tw.hover_opacity_70

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
          Tw.relative;
          Tw.inline_flex;
          Tw.items_center;
          Tw.justify_center;
          Tw.overflow_hidden;
          Tw.bg_gray_100;
          Tw.rounded_full;
          Tw.dark_bg_gray_600;
        ]
      @ opacity_classes)
    [ span ~tw:[ Tw.font_medium; Tw.text_gray_300 ] [ txt initials ] ]

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
      let ring_classes =
        match ring with Some _ -> [ Tw.ring_2; Tw.ring_white ] | None -> []
      in
      div
        ~tw:
          (size_classes size
          @ [ Tw.rounded_full; Tw.bg_gray_100; Tw.overflow_hidden; Tw.m_1 ]
          @ opacity_classes @ ring_classes)
        [
          img
            ~at:[ At.src avatar; At.alt author.name; At.loading_lazy ]
            ~tw:[ Tw.w_full; Tw.h_full; Tw.object_cover ]
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
