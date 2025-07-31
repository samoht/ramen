(** Color definitions and semantic color mappings for the UI *)

(** {1 Color Palette} *)

(* The color palette type defines the core colors used throughout the UI *)
type palette = {
  primary : Tw.color;
  secondary : Tw.color;
  accent : Tw.color;
  neutral : Tw.color;
}

(* Default color palette for the design system *)
let default_palette =
  { primary = Tw.sky; secondary = Tw.teal; accent = Tw.blue; neutral = Tw.gray }

(** {1 Color Generation Functions} *)

(* Functions to generate colors based on a palette *)
let text_primary palette = Tw.(text ~shade:900 palette.neutral)
let text_secondary palette = Tw.(text ~shade:700 palette.neutral)
let text_muted palette = Tw.(text ~shade:500 palette.neutral)
let bg_primary _palette = Tw.(bg white) (* For now, keep white as primary bg *)
let bg_secondary palette = Tw.(bg ~shade:50 palette.neutral)
let border_muted palette = Tw.(border_color ~shade:200 palette.neutral)
let border_accent palette = Tw.(border_color ~shade:600 palette.accent)

let hover_text_primary palette =
  Tw.(on_hover [ text ~shade:900 palette.primary ])

let pp_palette palette =
  Core.Pp.record
    [
      ("primary", Tw.color_to_string palette.primary);
      ("secondary", Tw.color_to_string palette.secondary);
      ("accent", Tw.color_to_string palette.accent);
      ("neutral", Tw.color_to_string palette.neutral);
    ]
