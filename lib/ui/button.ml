open Html

type variant = Primary | Secondary | Outline

let variant_styles = function
  | Primary ->
      Tw.
        [
          bg ~shade:600 sky;
          text white;
          shadow sm;
          on_hover [ bg ~shade:500 sky ];
          focus_visible;
          outline_none;
          (* ring_2; (* Removed shortcut *) ring_offset_2; *)
        ]
  | Secondary ->
      Tw.
        [
          bg ~shade:100 gray;
          text ~shade:900 gray;
          shadow sm;
          on_hover [ bg ~shade:200 gray ];
        ]
  | Outline ->
      Tw.
        [
          border `Default;
          border_color ~shade:300 gray;
          bg white;
          text ~shade:700 gray;
          on_hover [ bg ~shade:50 gray ];
        ]

let size_styles = function
  | `Small -> Tw.[ px (int 2); py (int 1); text_xs ]
  | `Medium -> Tw.[ px (int 3); py (int 2); text_sm ]
  | `Large -> Tw.[ px (int 5); py (int 3); text_base ]

let base_styles =
  Tw.
    [
      rounded md;
      font_semibold;
      transition_colors;
      inline_flex;
      items_center;
      justify_center;
      (* w_fit; *)
      (* Use compositional form instead *)
    ]

let render ?(variant = Primary) ?(size = `Medium) ~href label =
  let styles = base_styles @ variant_styles variant @ size_styles size in
  a ~at:[ At.href href ] ~tw:styles [ txt label ]
