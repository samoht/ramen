open Html

type style =
  | Gradient (* Index page style with gradient background *)
  | Simple (* Blog/Papers style with plain background *)
  | Post (* Blog post style with border *)

(* Helper function to render subtitle if present *)
let render_subtitle ?(centered = false) ~palette subtitle =
  match subtitle with
  | None -> void
  | Some sub ->
      let classes =
        if centered then
          [
            Tw.text_base;
            Colors.text_muted palette;
            Tw.mt_2;
            Tw.italic;
            Tw.max_w_2xl;
            Tw.mx_auto;
          ]
        else [ Tw.text_base; Colors.text_muted palette; Tw.mt_2; Tw.italic ]
      in
      p ~tw:classes [ txt sub ]

(* Helper to render gradient background effects *)
let render_gradient_background () =
  div
    ~tw:[ Tw.absolute; Tw.inset_0; Tw.opacity_30; Tw.pointer_events_none ]
    [
      (* Grid pattern overlay *)
      div
        ~at:
          [
            At.style
              "background-image: linear-gradient(rgba(14, 165, 233, 0.1) 1px, \
               transparent 1px), linear-gradient(90deg, rgba(14, 165, 233, \
               0.1) 1px, transparent 1px); background-size: 50px 50px;";
          ]
        ~tw:[ Tw.absolute; Tw.inset_0 ]
        [];
      (* Floating particles effect *)
      div
        ~at:
          [
            At.style
              "position: absolute; width: 100%%; height: 100%%; \
               background-image: radial-gradient(circle, rgba(14, 165, 233, \
               0.2) 1px, transparent 1px), radial-gradient(circle, rgba(99, \
               102, 241, 0.2) 1px, transparent 1px); background-size: 80px \
               80px, 110px 110px; background-position: 0 0, 30px 30px;";
          ]
        ~tw:[ Tw.opacity_50 ] [];
    ]

(* Helper to render circuit decorations *)
let render_circuit_decorations () =
  div
    ~tw:
      [
        Tw.absolute;
        Tw.inset_0;
        Tw.pointer_events_none;
        Tw.flex;
        Tw.items_center;
        Tw.justify_center;
      ]
    [
      (* Camel on the left *)
      div
        ~at:[ Html.At.style "left: -100px; top: 50%" ]
        ~tw:
          [
            Tw.absolute;
            Tw.neg_mt_56;
            Tw.pt_56;
            Tw.scale_150;
            Tw.sm_transform_none;
          ]
        [];
      (* Boat on the right *)
      div
        ~at:[ At.style "right: -100px; top: 50%" ]
        ~tw:
          [
            Tw.absolute;
            Tw.neg_mt_56;
            Tw.pt_56;
            Tw.scale_150;
            Tw.sm_transform_none;
          ]
        [];
    ]

(* Render gradient style hero *)
let render_gradient ~title ~description ~subtitle ~palette =
  section
    ~tw:
      [
        Tw.relative;
        Tw.py_20;
        Tw.bg_gradient_to_br;
        Tw.from_sky_50;
        Tw.via_blue_50;
        Tw.to_indigo_50;
        Tw.overflow_hidden;
      ]
    [
      render_gradient_background ();
      (* Content *)
      div
        ~tw:[ Tw.relative; Tw.max_w_4xl; Tw.mx_auto; Tw.px_6; Tw.z_10 ]
        [
          h1
            ~tw:
              [
                Tw.text_4xl;
                Tw.sm_text_5xl;
                Tw.font_bold;
                Colors.text_primary palette;
                Tw.mb_4;
              ]
            [ txt title ];
          p
            ~tw:[ Tw.text_lg; Colors.text_muted palette; Tw.leading_relaxed ]
            [ txt description ];
          render_subtitle ~palette subtitle;
          void;
        ];
    ]

(* Render simple style hero with circuit decorations *)
let render_simple ~title ~description ~subtitle ~palette =
  section
    ~tw:[ Tw.bg_white; Tw.py_24; Tw.relative; Tw.overflow_hidden ]
    [
      render_circuit_decorations ();
      (* Content *)
      div
        ~tw:
          [
            Tw.relative;
            Tw.z_10;
            Tw.max_w_4xl;
            Tw.mx_auto;
            Tw.px_6;
            Tw.mb_12;
            Tw.text_center;
          ]
        [
          h1
            ~tw:
              [
                Tw.text_4xl;
                Tw.sm_text_5xl;
                Tw.font_bold;
                Colors.text_primary palette;
                Tw.mb_4;
              ]
            [ txt title ];
          p
            ~tw:
              [
                Tw.text_lg; Colors.text_muted palette; Tw.max_w_2xl; Tw.mx_auto;
              ]
            [ txt description ];
          render_subtitle ~centered:true ~palette subtitle;
        ];
    ]

(* Render post style hero *)
let render_post ~title ~subtitle ~palette =
  section
    ~tw:[ Tw.bg_white; Tw.border_b; Colors.border_muted palette; Tw.py_24 ]
    [
      div
        ~tw:[ Tw.max_w_4xl; Tw.mx_auto; Tw.px_6 ]
        [
          h1
            ~tw:
              [
                Tw.text_3xl;
                Tw.sm_text_4xl;
                Tw.font_bold;
                Colors.text_primary palette;
                Tw.mb_4;
              ]
            [ txt title ];
          (match subtitle with
          | None -> void
          | Some sub ->
              span ~tw:[ Tw.text_sm; Colors.text_muted palette ] [ txt sub ]);
        ];
    ]

type t = {
  style : style option;
  title : string;
  description : string;
  subtitle : string option;
  palette : Colors.palette;
}
(** Component data for hero sections *)

(* Main render function *)
let render t =
  let style = Option.value t.style ~default:Gradient in
  match style with
  | Gradient ->
      render_gradient ~title:t.title ~description:t.description
        ~subtitle:t.subtitle ~palette:t.palette
  | Simple ->
      render_simple ~title:t.title ~description:t.description
        ~subtitle:t.subtitle ~palette:t.palette
  | Post -> render_post ~title:t.title ~subtitle:t.subtitle ~palette:t.palette

let pp t =
  let pp_style = function
    | Gradient -> "Gradient"
    | Simple -> "Simple"
    | Post -> "Post"
  in
  Core.Pp.record
    [
      ("style", Core.Pp.option pp_style t.style);
      ("title", Core.Pp.quote t.title);
      ("description", Core.Pp.quote t.description);
      ("subtitle", Core.Pp.option Core.Pp.quote t.subtitle);
      ("palette", Colors.pp_palette t.palette);
    ]
