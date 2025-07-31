open Html
open Tw

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
            text_base;
            Colors.text_muted palette;
            mt (int 2);
            italic;
            max_w xl_2;
            mx auto;
          ]
        else [ text_base; Colors.text_muted palette; mt (int 2); italic ]
      in
      Html.p ~tw:classes [ txt sub ]

(* Helper to render gradient background effects *)
let render_gradient_background () =
  div
    ~tw:[ absolute; inset_0; opacity 30; pointer_events_none ]
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
        ~tw:[ absolute; inset_0 ] [];
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
        ~tw:[ opacity 50 ]
        [];
    ]

(* Helper to render circuit decorations *)
let render_circuit_decorations () =
  div
    ~tw:
      [
        absolute;
        inset_0;
        pointer_events_none;
        flex;
        items_center;
        justify_center;
      ]
    [
      (* Camel on the left *)
      div
        ~at:[ At.style "left: -100px; top: 50%" ]
        ~tw:
          [
            absolute;
            neg_mt (int 56);
            pt (int 56);
            scale 150;
            on_sm [ transform_none ];
          ]
        [];
      (* Boat on the right *)
      div
        ~at:[ At.style "right: -100px; top: 50%" ]
        ~tw:
          [
            absolute;
            neg_mt (int 56);
            pt (int 56);
            scale 150;
            on_sm [ transform_none ];
          ]
        [];
    ]

(* Render gradient style hero *)
let render_gradient ~title ~description ~subtitle ~palette =
  section
    ~tw:
      [
        relative;
        py (int 20);
        bg_gradient_to_br;
        from_color ~shade:50 sky;
        to_color ~shade:50 indigo;
        overflow_hidden;
      ]
    [
      render_gradient_background ();
      (* Content *)
      div
        ~tw:
          [
            relative;
            max_w (rem 56.0) (* 4xl = 56rem *);
            mx auto;
            px (int 6);
            z 10;
          ]
        [
          h1
            ~tw:
              [
                text_4xl;
                on_sm [ text_5xl ];
                font_bold;
                Colors.text_primary palette;
                mb (int 4);
              ]
            [ txt title ];
          Html.p
            ~tw:[ text_lg; Colors.text_muted palette; leading_relaxed ]
            [ txt description ];
          render_subtitle ~palette subtitle;
          void;
        ];
    ]

(* Render simple style hero with circuit decorations *)
let render_simple ~title ~description ~subtitle ~palette =
  section
    ~tw:[ bg white; py (int 24); relative; overflow_hidden ]
    [
      render_circuit_decorations ();
      (* Content *)
      div
        ~tw:
          [
            relative;
            z 10;
            max_w xl_4;
            mx auto;
            px (int 6);
            mb (int 12);
            text_center;
          ]
        [
          h1
            ~tw:
              [
                text_4xl;
                on_sm [ text_5xl ];
                font_bold;
                Colors.text_primary palette;
                mb (int 4);
              ]
            [ txt title ];
          Html.p
            ~tw:
              [
                text_lg;
                Colors.text_muted palette;
                max_w (rem 42.0) (* 2xl = 42rem *);
                mx auto;
              ]
            [ txt description ];
          render_subtitle ~centered:true ~palette subtitle;
        ];
    ]

(* Render post style hero *)
let render_post ~title ~subtitle ~palette =
  section
    ~tw:[ bg white; border_b; Colors.border_muted palette; py (int 24) ]
    [
      div
        ~tw:[ max_w (rem 56.0) (* 4xl = 56rem *); mx auto; px (int 6) ]
        [
          h1
            ~tw:
              [
                text_3xl;
                on_sm [ text_4xl ];
                font_bold;
                Colors.text_primary palette;
                mb (int 4);
              ]
            [ txt title ];
          (match subtitle with
          | None -> void
          | Some sub ->
              span ~tw:[ text_sm; Colors.text_muted palette ] [ txt sub ]);
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
