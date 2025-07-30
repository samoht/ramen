open Html

type variant = Primary | Secondary | Outline

let variant_styles = function
  | Primary ->
      Tw.
        [
          bg ~shade:600 Sky;
          text_white;
          shadow Sm;
          hover (bg ~shade:500 Sky);
          focus_visible;
          outline_none;
          ring_2;
          ring_offset_2;
        ]
  | Secondary ->
      Tw.
        [
          bg ~shade:100 Gray;
          text ~shade:900 Gray;
          shadow Sm;
          hover (bg ~shade:200 Gray);
        ]
  | Outline ->
      Tw.
        [
          border;
          border_color ~shade:300 Gray;
          bg_white;
          text ~shade:700 Gray;
          hover (bg ~shade:50 Gray);
        ]

let size_styles = function
  | `Small -> Tw.[ px (Int 2); py (Int 1); text_xs ]
  | `Medium -> Tw.[ px (Int 3); py (Int 2); text_sm ]
  | `Large -> Tw.[ px (Int 5); py (Int 3); text_base ]

let base_styles =
  Tw.
    [
      rounded Md;
      font_semibold;
      transition_colors;
      inline_flex;
      items_center;
      justify_center;
      w_fit;
    ]

let render ?(variant = Primary) ?(size = `Medium) ~href label =
  let styles = base_styles @ variant_styles variant @ size_styles size in
  a ~at:[ At.href href ] ~tw:styles [ txt label ]
