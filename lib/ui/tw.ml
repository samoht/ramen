(** A type-safe, ergonomic DSL for Tailwind CSS using nominal types. *)

(** {1 Core Types} *)

type color =
  | Black
  | White
  | Gray
  | Red
  | Yellow
  | Green
  | Blue
  | Indigo
  | Purple
  | Pink
  | Sky
  | Teal

type spacing = Px | Full | Val of float | Int of int
type margin = Auto | Px | Full | Val of float | Int of int
type size = Screen | Px | Full | Val of float | Int of int
type shadow = None | Sm | Md | Lg | Xl | Xl_2 | Inner
type rounded = None | Sm | Md | Lg | Xl | Xl_2 | Xl_3 | Full

type modifier =
  | Hover
  | Focus
  | Active
  | Disabled
  | Group_hover
  | Dark
  | Responsive of string

type t =
  | Style of string * Css.property list (* class name, properties *)
  | Modified of modifier * t

(** {1 Helper Functions} *)

let color_to_hex color shade =
  match (color, shade) with
  (* Basic colors *)
  | Black, _ -> "#000000"
  | White, _ -> "#ffffff"
  | Gray, 50 -> "#f9fafb"
  | Gray, 100 -> "#f3f4f6"
  | Gray, 500 -> "#6b7280"
  | Gray, 900 -> "#111827"
  | Sky, 100 -> "#e0f2fe"
  | Sky, 600 -> "#0284c7"
  | Sky, 700 -> "#0369a1"
  | Sky, 800 -> "#075985"
  | Sky, 900 -> "#0c4a6e"
  | Yellow, 400 -> "#facc15"
  | Teal, 600 -> "#0d9488"
  | _, _ -> "#6b7280" (* fallback *)

let spacing_to_rem = function
  | 0 -> "0"
  | 1 -> "0.25rem"
  | 2 -> "0.5rem"
  | 3 -> "0.75rem"
  | 4 -> "1rem"
  | 6 -> "1.5rem"
  | 8 -> "2rem"
  | 10 -> "2.5rem"
  | 12 -> "3rem"
  | 16 -> "4rem"
  | 20 -> "5rem"
  | 24 -> "6rem"
  | 56 -> "14rem"
  | n -> string_of_int n ^ "rem"

(** {1 Public API} *)

(* Colors *)
let color_name = function
  | Black -> "black"
  | White -> "white"
  | Gray -> "gray"
  | Red -> "red"
  | Yellow -> "yellow"
  | Green -> "green"
  | Blue -> "blue"
  | Indigo -> "indigo"
  | Purple -> "purple"
  | Pink -> "pink"
  | Sky -> "sky"
  | Teal -> "teal"

let bg ?(shade = 500) color =
  let class_name =
    Core.Pp.str [ "bg-"; color_name color; "-"; string_of_int shade ]
  in
  Style (class_name, [ (Css.Background_color, color_to_hex color shade) ])

let bg_transparent =
  Style ("bg-transparent", [ (Css.Background_color, "transparent") ])

let bg_current = Style ("bg-current", [ (Css.Background_color, "currentColor") ])

let text ?(shade = 500) color =
  let class_name =
    Core.Pp.str [ "text-"; color_name color; "-"; string_of_int shade ]
  in
  Style (class_name, [ (Css.Color, color_to_hex color shade) ])

let text_transparent = Style ("text-transparent", [ (Css.Color, "transparent") ])
let text_current = Style ("text-current", [ (Css.Color, "currentColor") ])

let border_color ?(shade = 500) color =
  let class_name =
    Core.Pp.str [ "border-"; color_name color; "-"; string_of_int shade ]
  in
  Style (class_name, [ (Css.Border_color, color_to_hex color shade) ])

let border_transparent =
  Style ("border-transparent", [ (Css.Border_color, "transparent") ])

let border_current =
  Style ("border-current", [ (Css.Border_color, "currentColor") ])

let spacing_class_suffix : spacing -> string = function
  | Int n -> string_of_int n
  | Px -> "px"
  | Full -> "full"
  | Val f -> Core.Pp.str [ string_of_float f ]

let size_class_suffix = function
  | Screen -> "screen"
  | Int n -> string_of_int n
  | Px -> "px"
  | Full -> "full"
  | Val f -> Core.Pp.str [ string_of_float f ]

let margin_class_suffix = function
  | Auto -> "auto"
  | Int n -> string_of_int n
  | Px -> "px"
  | Full -> "full"
  | Val f -> Core.Pp.str [ string_of_float f ]

let spacing_to_string : spacing -> string = function
  | Int n ->
      (* Tailwind uses 0.25rem (4px) as base unit, so n * 0.25rem *)
      let rem_value = float_of_int n *. 0.25 in
      Core.Pp.str [ Core.Pp.float rem_value; "rem" ]
  | Px -> "1px"
  | Full -> "100%"
  | Val f -> Core.Pp.str [ Core.Pp.float f; "rem" ]

let margin_to_string = function
  | Auto -> "auto"
  | Int n ->
      (* Tailwind uses 0.25rem (4px) as base unit, so n * 0.25rem *)
      let rem_value = float_of_int n *. 0.25 in
      Core.Pp.str [ Core.Pp.float rem_value; "rem" ]
  | Px -> "1px"
  | Full -> "100%"
  | Val f -> Core.Pp.str [ Core.Pp.float f; "rem" ]

let size_to_string = function
  | Screen -> "100vh"
  | Int n ->
      (* Tailwind uses 0.25rem (4px) as base unit, so n * 0.25rem *)
      let rem_value = float_of_int n *. 0.25 in
      Core.Pp.str [ Core.Pp.float rem_value; "rem" ]
  | Px -> "1px"
  | Full -> "100%"
  | Val f -> Core.Pp.str [ Core.Pp.float f; "rem" ]

(* Spacing *)
let p s =
  let class_name = "p-" ^ spacing_class_suffix s in
  Style (class_name, [ (Css.Padding, spacing_to_string s) ])

let px s =
  let v = spacing_to_string s in
  let class_name = "px-" ^ spacing_class_suffix s in
  Style (class_name, [ (Css.Padding_left, v); (Css.Padding_right, v) ])

let py s =
  let v = spacing_to_string s in
  let class_name = "py-" ^ spacing_class_suffix s in
  Style (class_name, [ (Css.Padding_top, v); (Css.Padding_bottom, v) ])

let pt s =
  let class_name = "pt-" ^ spacing_class_suffix s in
  Style (class_name, [ (Css.Padding_top, spacing_to_string s) ])

let pr s =
  let class_name = "pr-" ^ spacing_class_suffix s in
  Style (class_name, [ (Css.Padding_right, spacing_to_string s) ])

let pb s =
  let class_name = "pb-" ^ spacing_class_suffix s in
  Style (class_name, [ (Css.Padding_bottom, spacing_to_string s) ])

let pl s =
  let class_name = "pl-" ^ spacing_class_suffix s in
  Style (class_name, [ (Css.Padding_left, spacing_to_string s) ])

let m m =
  let class_name = "m-" ^ margin_class_suffix m in
  Style (class_name, [ (Css.Margin, margin_to_string m) ])

let mx m =
  let v = margin_to_string m in
  let class_name = "mx-" ^ margin_class_suffix m in
  Style (class_name, [ (Css.Margin_left, v); (Css.Margin_right, v) ])

let my m =
  let v = margin_to_string m in
  let class_name = "my-" ^ margin_class_suffix m in
  Style (class_name, [ (Css.Margin_top, v); (Css.Margin_bottom, v) ])

let mt m =
  let class_name = "mt-" ^ margin_class_suffix m in
  Style (class_name, [ (Css.Margin_top, margin_to_string m) ])

let mr m =
  let class_name = "mr-" ^ margin_class_suffix m in
  Style (class_name, [ (Css.Margin_right, margin_to_string m) ])

let mb m =
  let class_name = "mb-" ^ margin_class_suffix m in
  Style (class_name, [ (Css.Margin_bottom, margin_to_string m) ])

let ml m =
  let class_name = "ml-" ^ margin_class_suffix m in
  Style (class_name, [ (Css.Margin_left, margin_to_string m) ])

let gap s =
  let class_name = "gap-" ^ spacing_class_suffix s in
  Style (class_name, [ (Css.Gap, spacing_to_string s) ])

let gap_x s =
  let class_name = "gap-x-" ^ spacing_class_suffix s in
  Style (class_name, [ (Css.Column_gap, spacing_to_string s) ])

let gap_y s =
  let class_name = "gap-y-" ^ spacing_class_suffix s in
  Style (class_name, [ (Css.Row_gap, spacing_to_string s) ])

let space_x s =
  let class_name = "space-x-" ^ spacing_class_suffix s in
  (* space-x is a Tailwind utility that uses CSS variables, we'll skip it for
     now *)
  Style (class_name, [])

let space_y s =
  let class_name = "space-y-" ^ spacing_class_suffix s in
  (* space-y is a Tailwind utility that uses CSS variables, we'll skip it for
     now *)
  Style (class_name, [])

(* Sizing *)
let w s =
  let class_name = "w-" ^ size_class_suffix s in
  Style (class_name, [ (Css.Width, size_to_string s) ])

let w_auto = Style ("w-auto", [ (Css.Width, "auto") ])
let w_full = Style ("w-full", [ (Css.Width, "100%") ])

let h s =
  let class_name = "h-" ^ size_class_suffix s in
  match s with
  | Screen -> Style (class_name, [ (Css.Height, "100vh") ])
  | _ -> Style (class_name, [ (Css.Height, size_to_string s) ])

let h_auto = Style ("h-auto", [ (Css.Height, "auto") ])
let h_full = Style ("h-full", [ (Css.Height, "100%") ])

let min_w s =
  let class_name = "min-w-" ^ spacing_class_suffix s in
  Style (class_name, [ (Css.Min_width, spacing_to_string s) ])

let min_h s =
  let class_name = "min-h-" ^ size_class_suffix s in
  match s with
  | Screen -> Style (class_name, [ (Css.Min_height, "100vh") ])
  | _ -> Style (class_name, [ (Css.Min_height, size_to_string s) ])

let min_h_screen = min_h Screen

let max_w s =
  let class_name = "max-w-" ^ spacing_class_suffix s in
  Style (class_name, [ (Css.Max_width, spacing_to_string s) ])

let max_w_7xl = Style ("max-w-7xl", [ (Css.Max_width, "80rem") ])

(* Typography *)
let text_xs =
  Style ("text-xs", [ (Css.Font_size, "0.75rem"); (Css.Line_height, "1rem") ])

let text_sm =
  Style
    ("text-sm", [ (Css.Font_size, "0.875rem"); (Css.Line_height, "1.25rem") ])

let text_xl =
  Style ("text-xl", [ (Css.Font_size, "1.25rem"); (Css.Line_height, "1.75rem") ])

let text_2xl =
  Style ("text-2xl", [ (Css.Font_size, "1.5rem"); (Css.Line_height, "2rem") ])

let font_medium = Style ("font-medium", [ (Css.Font_weight, "500") ])
let font_bold = Style ("font-bold", [ (Css.Font_weight, "700") ])
let text_center = Style ("text-center", [ (Css.Text_align, "center") ])

(* Display & Layout *)
let block = Style ("block", [ (Css.Display, "block") ])
let flex = Style ("flex", [ (Css.Display, "flex") ])
let hidden = Style ("hidden", [ (Css.Display, "none") ])
let flex_shrink_0 = Style ("flex-shrink-0", [ (Css.Flex_shrink, "0") ])
let items_center = Style ("items-center", [ (Css.Align_items, "center") ])

let justify_between =
  Style ("justify-between", [ (Css.Justify_content, "space-between") ])

(* Borders *)

(* Modifiers *)
let hover t = Modified (Hover, t)
let md t = Modified (Responsive "md", t)

(* Common shortcuts *)
let px_3 = px (Int 3)
let px_4 = px (Int 4)
let px_6 = px (Int 6)
let px_8 = px (Int 8)
let py_2 = py (Int 2)
let py_8 = py (Int 8)
let py_20 = py (Int 20)
let py_24 = py (Int 24)
let pt_56 = pt (Int 56)
let pb_4 = pb (Int 4)
let pb_2 = pb (Int 2)
let pb_8 = pb (Int 8)
let pb_12 = pb (Int 12)
let mx_auto = mx Auto
let ml_4 = ml (Int 4)
let ml_10 = ml (Int 10)
let mb_4 = mb (Int 4)
let mb_12 = mb (Int 12)
let mt_2 = mt (Int 2)
let gap_2 = gap (Int 2)
let gap_4 = gap (Int 4)
let space_x_4 = space_x (Int 4)
let w_6 = w (Int 6)
let w_8 = w (Int 8)
let w_10 = w (Int 10)
let w_12 = w (Int 12)
let w_16 = w (Int 16)
let h_6 = h (Int 6)
let h_8 = h (Int 8)
let h_16 = h (Int 16)
let text_white = text White
let text_black = text Black
let text_gray_400 = text ~shade:400 Gray
let text_gray_500 = text ~shade:500 Gray
let text_gray_600 = text ~shade:600 Gray
let text_gray_700 = text ~shade:700 Gray
let text_gray_900 = text ~shade:900 Gray
let text_sky_100 = text ~shade:100 Sky
let text_sky_700 = text ~shade:700 Sky
let text_sky_900 = text ~shade:900 Sky
let text_teal_600 = text ~shade:600 Teal
let bg_white = bg White
let bg_black = bg Black
let bg_gray_50 = bg ~shade:50 Gray
let bg_gray_100 = bg ~shade:100 Gray
let bg_sky_600 = bg ~shade:600 Sky
let bg_sky_700 = bg ~shade:700 Sky
let bg_sky_800 = bg ~shade:800 Sky
let bg_sky_900 = bg ~shade:900 Sky
let border_gray_200 = border_color ~shade:200 Gray
let border_teal_600 = border_color ~shade:600 Teal
let hover_text_gray_900 = hover (text ~shade:900 Gray)
let hover_text_sky_600 = hover (text ~shade:600 Sky)
let hover_text_white = hover text_white
let hover_bg_sky_800 = hover bg_sky_800
let hover_border_gray_300 = hover (border_color ~shade:300 Gray)
let md_block = md block
let md_ml_6 = md (ml (Int 6))
let opacity_50 = Style ("opacity-50", [ (Css.Opacity, "0.5") ])

(** {1 CSS Generation} *)

let rec to_css_properties = function
  | Style (_class_name, props) -> props
  | Modified (_modifier, t) -> to_css_properties t

let to_css_rule ~selector styles =
  let properties = styles |> List.concat_map to_css_properties in
  Css.rule ~selector properties

let to_stylesheet selector_styles =
  let rules =
    selector_styles
    |> List.map (fun (selector, styles) -> to_css_rule ~selector styles)
  in
  Css.stylesheet rules

(* Helper to get breakpoint for responsive prefix *)
let responsive_breakpoint = function
  | "sm" -> "640px"
  | "md" -> "768px"
  | "lg" -> "1024px"
  | "xl" -> "1280px"
  | "2xl" -> "1536px"
  | _ -> "0px"

(* Extract selector and properties from a single Tw style *)
let extract_selector_props tw =
  let rec extract = function
    | Style (class_name, props) -> [ ("." ^ class_name, props) ]
    | Modified (modifier, t) ->
        let base = extract t in
        List.map
          (fun (selector, props) ->
            match modifier with
            | Hover -> (selector ^ ":hover", props)
            | Focus -> (selector ^ ":focus", props)
            | Active -> (selector ^ ":active", props)
            | Disabled -> (selector ^ ":disabled", props)
            | Group_hover -> (".group:hover " ^ selector, props)
            | Dark ->
                ("@media (prefers-color-scheme: dark) { " ^ selector, props)
            | Responsive prefix ->
                ( "@media (min-width: "
                  ^ responsive_breakpoint prefix
                  ^ ") { " ^ selector,
                  props ))
          base
  in
  extract tw

(* Group properties by selector *)
let group_by_selector rules =
  List.fold_left
    (fun acc (selector, props) ->
      let existing = try List.assoc selector acc with Not_found -> [] in
      (selector, existing @ props) :: List.remove_assoc selector acc)
    [] rules

(* Base reset CSS rules *)
let reset_rules =
  [
    Css.rule ~selector:"*"
      [
        (Css.Margin, "0");
        (Css.Padding, "0");
        (Css.Custom "box-sizing", "border-box");
      ];
    Css.rule ~selector:"body"
      [
        (Css.Font_size, "16px");
        (Css.Line_height, "1.5");
        (Css.Color, "#374151");
        ( Css.Custom "font-family",
          "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica \
           Neue', Arial, sans-serif" );
      ];
  ]

(* Generate CSS rules for all used Tw classes *)
let of_tw tw_classes =
  let all_rules =
    tw_classes |> List.concat_map extract_selector_props |> group_by_selector
  in
  let rules =
    List.map
      (fun (selector, props) ->
        Css.rule ~selector (Css.deduplicate_properties props))
      all_rules
  in
  Css.stylesheet (reset_rules @ rules)

let color_to_string = function
  | Black -> "black"
  | White -> "white"
  | Gray -> "gray"
  | Red -> "red"
  | Yellow -> "yellow"
  | Green -> "green"
  | Blue -> "blue"
  | Indigo -> "indigo"
  | Purple -> "purple"
  | Pink -> "pink"
  | Sky -> "sky"
  | Teal -> "teal"

let spacing_to_class_suffix = function
  | 0 -> "0"
  | 1 -> "1"
  | 2 -> "2"
  | 3 -> "3"
  | 4 -> "4"
  | 6 -> "6"
  | 8 -> "8"
  | 10 -> "10"
  | 12 -> "12"
  | 16 -> "16"
  | 20 -> "20"
  | 24 -> "24"
  | 56 -> "56"
  | n -> string_of_int n

(* Additional missing functions needed by tw.mli *)
let p_1 = p (Int 1)
let m_1 = m (Int 1)

let neg_mt s =
  let class_name = "-mt-" ^ spacing_class_suffix s in
  Style (class_name, [ (Css.Margin_top, "-" ^ spacing_to_string s) ])

let neg_mr s =
  let class_name = "-mr-" ^ spacing_class_suffix s in
  Style (class_name, [ (Css.Margin_right, "-" ^ spacing_to_string s) ])

let neg_mb s =
  let class_name = "-mb-" ^ spacing_class_suffix s in
  Style (class_name, [ (Css.Margin_bottom, "-" ^ spacing_to_string s) ])

let neg_ml s =
  let class_name = "-ml-" ^ spacing_class_suffix s in
  Style (class_name, [ (Css.Margin_left, "-" ^ spacing_to_string s) ])

let neg_mt_56 = neg_mt (Int 56)
let w_min = Style ("w-min", [ (Css.Width, "min-content") ])
let w_max = Style ("w-max", [ (Css.Width, "max-content") ])
let w_fit = Style ("w-fit", [ (Css.Width, "fit-content") ])
let h_min = Style ("h-min", [ (Css.Height, "min-content") ])
let h_max = Style ("h-max", [ (Css.Height, "max-content") ])
let h_fit = Style ("h-fit", [ (Css.Height, "fit-content") ])
let h_10 = h (Int 10)
let h_12 = h (Int 12)
let min_w_min = Style ("min-w-min", [ (Css.Min_width, "min-content") ])
let min_w_max = Style ("min-w-max", [ (Css.Min_width, "max-content") ])
let min_w_fit = Style ("min-w-fit", [ (Css.Min_width, "fit-content") ])
let min_h_min = Style ("min-h-min", [ (Css.Min_height, "min-content") ])
let min_h_max = Style ("min-h-max", [ (Css.Min_height, "max-content") ])
let min_h_fit = Style ("min-h-fit", [ (Css.Min_height, "fit-content") ])
let max_w_none = Style ("max-w-none", [ (Css.Max_width, "none") ])
let max_w_xs = Style ("max-w-xs", [ (Css.Max_width, "20rem") ])
let max_w_sm = Style ("max-w-sm", [ (Css.Max_width, "24rem") ])
let max_w_md = Style ("max-w-md", [ (Css.Max_width, "28rem") ])
let max_w_lg = Style ("max-w-lg", [ (Css.Max_width, "32rem") ])
let max_w_xl = Style ("max-w-xl", [ (Css.Max_width, "36rem") ])
let max_w_2xl = Style ("max-w-2xl", [ (Css.Max_width, "42rem") ])
let max_w_3xl = Style ("max-w-3xl", [ (Css.Max_width, "48rem") ])
let max_w_4xl = Style ("max-w-4xl", [ (Css.Max_width, "56rem") ])
let max_w_5xl = Style ("max-w-5xl", [ (Css.Max_width, "64rem") ])
let max_w_6xl = Style ("max-w-6xl", [ (Css.Max_width, "72rem") ])

let max_h s =
  let class_name = "max-h-" ^ size_class_suffix s in
  match s with
  | Screen -> Style (class_name, [ (Css.Max_height, "100vh") ])
  | _ -> Style (class_name, [ (Css.Max_height, size_to_string s) ])

let max_h_none = Style ("max-h-none", [ (Css.Max_height, "none") ])

let text_base =
  Style ("text-base", [ (Css.Font_size, "1rem"); (Css.Line_height, "1.5rem") ])

let text_lg =
  Style
    ("text-lg", [ (Css.Font_size, "1.125rem"); (Css.Line_height, "1.75rem") ])

let text_3xl =
  Style
    ("text-3xl", [ (Css.Font_size, "1.875rem"); (Css.Line_height, "2.25rem") ])

let text_4xl =
  Style ("text-4xl", [ (Css.Font_size, "2.25rem"); (Css.Line_height, "2.5rem") ])

let text_5xl =
  Style ("text-5xl", [ (Css.Font_size, "3rem"); (Css.Line_height, "1") ])

let font_thin = Style ("font-thin", [ (Css.Font_weight, "100") ])
let font_light = Style ("font-light", [ (Css.Font_weight, "300") ])
let font_normal = Style ("font-normal", [ (Css.Font_weight, "400") ])
let font_semibold = Style ("font-semibold", [ (Css.Font_weight, "600") ])
let font_extrabold = Style ("font-extrabold", [ (Css.Font_weight, "800") ])
let font_black = Style ("font-black", [ (Css.Font_weight, "900") ])
let italic = Style ("italic", [ (Css.Font_style, "italic") ])
let not_italic = Style ("not-italic", [ (Css.Font_style, "normal") ])
let underline = Style ("underline", [ (Css.Text_decoration, "underline") ])

let line_through =
  Style ("line-through", [ (Css.Text_decoration, "line-through") ])

let no_underline = Style ("no-underline", [ (Css.Text_decoration, "none") ])
let text_left = Style ("text-left", [ (Css.Text_align, "left") ])
let text_right = Style ("text-right", [ (Css.Text_align, "right") ])
let text_justify = Style ("text-justify", [ (Css.Text_align, "justify") ])
let leading_none = Style ("leading-none", [ (Css.Line_height, "1") ])
let leading_tight = Style ("leading-tight", [ (Css.Line_height, "1.25") ])
let leading_snug = Style ("leading-snug", [ (Css.Line_height, "1.375") ])
let leading_normal = Style ("leading-normal", [ (Css.Line_height, "1.5") ])
let leading_relaxed = Style ("leading-relaxed", [ (Css.Line_height, "1.625") ])
let leading_loose = Style ("leading-loose", [ (Css.Line_height, "2") ])
let leading_6 = Style ("leading-6", [ (Css.Line_height, "1.5rem") ])

let tracking_tighter =
  Style ("tracking-tighter", [ (Css.Letter_spacing, "-0.05em") ])

let tracking_tight =
  Style ("tracking-tight", [ (Css.Letter_spacing, "-0.025em") ])

let tracking_normal = Style ("tracking-normal", [ (Css.Letter_spacing, "0") ])
let tracking_wide = Style ("tracking-wide", [ (Css.Letter_spacing, "0.025em") ])
let tracking_wider = Style ("tracking-wider", [ (Css.Letter_spacing, "0.05em") ])

let tracking_widest =
  Style ("tracking-widest", [ (Css.Letter_spacing, "0.1em") ])

let whitespace_normal =
  Style ("whitespace-normal", [ (Css.White_space, "normal") ])

let whitespace_nowrap =
  Style ("whitespace-nowrap", [ (Css.White_space, "nowrap") ])

let whitespace_pre = Style ("whitespace-pre", [ (Css.White_space, "pre") ])

let whitespace_pre_line =
  Style ("whitespace-pre-line", [ (Css.White_space, "pre-line") ])

let whitespace_pre_wrap =
  Style ("whitespace-pre-wrap", [ (Css.White_space, "pre-wrap") ])

let group = Style ("group", [])
let inline_block = Style ("inline-block", [ (Css.Display, "inline-block") ])
let inline = Style ("inline", [ (Css.Display, "inline") ])
let inline_flex = Style ("inline-flex", [ (Css.Display, "inline-flex") ])
let grid = Style ("grid", [ (Css.Display, "grid") ])
let inline_grid = Style ("inline-grid", [ (Css.Display, "inline-grid") ])
let flex_row = Style ("flex-row", [ (Css.Flex_direction, "row") ])

let flex_row_reverse =
  Style ("flex-row-reverse", [ (Css.Flex_direction, "row-reverse") ])

let flex_col = Style ("flex-col", [ (Css.Flex_direction, "column") ])

let flex_col_reverse =
  Style ("flex-col-reverse", [ (Css.Flex_direction, "column-reverse") ])

let flex_wrap = Style ("flex-wrap", [ (Css.Flex_wrap, "wrap") ])

let flex_wrap_reverse =
  Style ("flex-wrap-reverse", [ (Css.Flex_wrap, "wrap-reverse") ])

let flex_nowrap = Style ("flex-nowrap", [ (Css.Flex_wrap, "nowrap") ])
let flex_1 = Style ("flex-1", [ (Css.Flex, "1 1 0%") ])
let flex_auto = Style ("flex-auto", [ (Css.Flex, "1 1 auto") ])
let flex_initial = Style ("flex-initial", [ (Css.Flex, "0 1 auto") ])
let flex_none = Style ("flex-none", [ (Css.Flex, "none") ])
let flex_grow = Style ("flex-grow", [ (Css.Flex_grow, "1") ])
let flex_grow_0 = Style ("flex-grow-0", [ (Css.Flex_grow, "0") ])
let flex_shrink = Style ("flex-shrink", [ (Css.Flex_shrink, "1") ])
let items_start = Style ("items-start", [ (Css.Align_items, "flex-start") ])
let items_end = Style ("items-end", [ (Css.Align_items, "flex-end") ])
let items_baseline = Style ("items-baseline", [ (Css.Align_items, "baseline") ])
let items_stretch = Style ("items-stretch", [ (Css.Align_items, "stretch") ])

let justify_start =
  Style ("justify-start", [ (Css.Justify_content, "flex-start") ])

let justify_end = Style ("justify-end", [ (Css.Justify_content, "flex-end") ])

let justify_center =
  Style ("justify-center", [ (Css.Justify_content, "center") ])

let justify_around =
  Style ("justify-around", [ (Css.Justify_content, "space-around") ])

let justify_evenly =
  Style ("justify-evenly", [ (Css.Justify_content, "space-evenly") ])

let grid_cols n =
  let class_name = "grid-cols-" ^ string_of_int n in
  Style
    ( class_name,
      [
        ( Css.Grid_template_columns,
          "repeat(" ^ string_of_int n ^ ", minmax(0, 1fr))" );
      ] )

let grid_rows n =
  let class_name = "grid-rows-" ^ string_of_int n in
  Style
    ( class_name,
      [
        ( Css.Grid_template_rows,
          "repeat(" ^ string_of_int n ^ ", minmax(0, 1fr))" );
      ] )

let static = Style ("static", [ (Css.Position, "static") ])
let fixed = Style ("fixed", [ (Css.Position, "fixed") ])
let absolute = Style ("absolute", [ (Css.Position, "absolute") ])
let relative = Style ("relative", [ (Css.Position, "relative") ])
let sticky = Style ("sticky", [ (Css.Position, "sticky") ])

let inset_0 =
  Style
    ( "inset-0",
      [ (Css.Top, "0"); (Css.Right, "0"); (Css.Bottom, "0"); (Css.Left, "0") ]
    )

let inset_x_0 = Style ("inset-x-0", [ (Css.Left, "0"); (Css.Right, "0") ])
let inset_y_0 = Style ("inset-y-0", [ (Css.Top, "0"); (Css.Bottom, "0") ])

let top n =
  let class_name = "top-" ^ string_of_int n in
  Style (class_name, [ (Css.Top, spacing_to_rem n) ])

let right n =
  let class_name = "right-" ^ string_of_int n in
  Style (class_name, [ (Css.Right, spacing_to_rem n) ])

let bottom n =
  let class_name = "bottom-" ^ string_of_int n in
  Style (class_name, [ (Css.Bottom, spacing_to_rem n) ])

let left n =
  let class_name = "left-" ^ string_of_int n in
  Style (class_name, [ (Css.Left, spacing_to_rem n) ])

let z n =
  let class_name = "z-" ^ string_of_int n in
  Style (class_name, [ (Css.Z_index, string_of_int n) ])

let z_10 = z 10
let border = Style ("border", [ (Css.Border_width, "1px") ])
let border_t = Style ("border-t", [ (Css.Border_top_width, "1px") ])
let border_r = Style ("border-r", [ (Css.Border_right_width, "1px") ])
let border_b = Style ("border-b", [ (Css.Border_bottom_width, "1px") ])
let border_l = Style ("border-l", [ (Css.Border_left_width, "1px") ])
let border_0 = Style ("border-0", [ (Css.Border_width, "0") ])
let border_2 = Style ("border-2", [ (Css.Border_width, "2px") ])
let border_4 = Style ("border-4", [ (Css.Border_width, "4px") ])
let border_8 = Style ("border-8", [ (Css.Border_width, "8px") ])

let rounded_value : rounded -> string = function
  | None -> "0"
  | Sm -> "0.125rem"
  | Md -> "0.375rem"
  | Lg -> "0.5rem"
  | Xl -> "0.75rem"
  | Xl_2 -> "1rem"
  | Xl_3 -> "1.5rem"
  | Full -> "9999px"

let rounded_class_suffix : rounded -> string = function
  | None -> "none"
  | Sm -> "sm"
  | Md -> "md"
  | Lg -> "lg"
  | Xl -> "xl"
  | Xl_2 -> "2xl"
  | Xl_3 -> "3xl"
  | Full -> "full"

let rounded r =
  let class_name = "rounded-" ^ rounded_class_suffix r in
  Style (class_name, [ (Css.Border_radius, rounded_value r) ])

let rounded_none = rounded None
let rounded_sm = rounded Sm
let rounded_lg = rounded Lg
let rounded_xl = rounded Xl
let rounded_2xl = rounded Xl_2
let rounded_3xl = rounded Xl_3
let rounded_full = rounded Full

let shadow_value : shadow -> string = function
  | None -> "none"
  | Sm -> "0 1px 2px 0 rgba(0, 0, 0, 0.05)"
  | Md ->
      "0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)"
  | Lg ->
      "0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)"
  | Xl ->
      "0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, \
       0.04)"
  | Xl_2 -> "0 25px 50px -12px rgba(0, 0, 0, 0.25)"
  | Inner -> "inset 0 2px 4px 0 rgba(0, 0, 0, 0.06)"

let shadow_class_suffix : shadow -> string = function
  | None -> "none"
  | Sm -> "sm"
  | Md -> "md"
  | Lg -> "lg"
  | Xl -> "xl"
  | Xl_2 -> "2xl"
  | Inner -> "inner"

let shadow s =
  let class_name = "shadow-" ^ shadow_class_suffix s in
  Style (class_name, [ (Css.Box_shadow, shadow_value s) ])

let shadow_sm = shadow Sm
let shadow_md = shadow Md
let shadow_lg = shadow Lg
let shadow_xl = shadow Xl
let shadow_2xl = shadow Xl_2
let shadow_inner = shadow Inner
let shadow_none = shadow None

let opacity n =
  let class_name = "opacity-" ^ string_of_int n in
  Style
    (class_name, [ (Css.Opacity, string_of_float (float_of_int n /. 100.0)) ])

let opacity_10 = opacity 10
let opacity_25 = Style ("opacity-25", [ (Css.Opacity, "0.25") ])
let opacity_30 = opacity 30
let transition_none = Style ("transition-none", [ (Css.Transition, "none") ])

let transition_all =
  Style
    ( "transition-all",
      [ (Css.Transition, "all 150ms cubic-bezier(0.4, 0, 0.2, 1)") ] )

let transition_colors =
  Style
    ( "transition-colors",
      [
        ( Css.Transition,
          "background-color, border-color, color, fill, stroke 150ms \
           cubic-bezier(0.4, 0, 0.2, 1)" );
      ] )

let transition_opacity =
  Style
    ( "transition-opacity",
      [ (Css.Transition, "opacity 150ms cubic-bezier(0.4, 0, 0.2, 1)") ] )

let transition_shadow =
  Style
    ( "transition-shadow",
      [ (Css.Transition, "box-shadow 150ms cubic-bezier(0.4, 0, 0.2, 1)") ] )

let transition_transform =
  Style
    ( "transition-transform",
      [ (Css.Transition, "transform 150ms cubic-bezier(0.4, 0, 0.2, 1)") ] )

let scale n =
  let class_name = "scale-" ^ string_of_int n in
  Style
    ( class_name,
      [
        ( Css.Transform,
          "scale(" ^ string_of_float (float_of_int n /. 100.0) ^ ")" );
      ] )

let scale_150 = scale 150

let rotate n =
  let class_name = "rotate-" ^ string_of_int n in
  Style (class_name, [ (Css.Transform, "rotate(" ^ string_of_int n ^ "deg)") ])

let translate_x n =
  let class_name = "translate-x-" ^ string_of_int n in
  Style (class_name, [ (Css.Transform, "translateX(" ^ spacing_to_rem n ^ ")") ])

let translate_y n =
  let class_name = "translate-y-" ^ string_of_int n in
  Style (class_name, [ (Css.Transform, "translateY(" ^ spacing_to_rem n ^ ")") ])

let cursor_auto = Style ("cursor-auto", [ (Css.Cursor, "auto") ])
let cursor_default = Style ("cursor-default", [ (Css.Cursor, "default") ])
let cursor_pointer = Style ("cursor-pointer", [ (Css.Cursor, "pointer") ])
let cursor_wait = Style ("cursor-wait", [ (Css.Cursor, "wait") ])
let cursor_move = Style ("cursor-move", [ (Css.Cursor, "move") ])

let cursor_not_allowed =
  Style ("cursor-not-allowed", [ (Css.Cursor, "not-allowed") ])

let select_none = Style ("select-none", [ (Css.User_select, "none") ])
let select_text = Style ("select-text", [ (Css.User_select, "text") ])
let select_all = Style ("select-all", [ (Css.User_select, "all") ])

let pointer_events_none =
  Style ("pointer-events-none", [ (Css.Pointer_events, "none") ])

let pointer_events_auto =
  Style ("pointer-events-auto", [ (Css.Pointer_events, "auto") ])

let outline_none = Style ("outline-none", [ (Css.Outline, "none") ])

let ring =
  Style ("ring", [ (Css.Box_shadow, "0 0 0 3px rgba(66, 153, 225, 0.5)") ])

let ring_0 = Style ("ring-0", [ (Css.Box_shadow, "none") ])

let ring_1 =
  Style ("ring-1", [ (Css.Box_shadow, "0 0 0 1px rgba(66, 153, 225, 0.5)") ])

let ring_2 =
  Style ("ring-2", [ (Css.Box_shadow, "0 0 0 2px rgba(66, 153, 225, 0.5)") ])

let ring_4 =
  Style ("ring-4", [ (Css.Box_shadow, "0 0 0 4px rgba(66, 153, 225, 0.5)") ])

let ring_8 =
  Style ("ring-8", [ (Css.Box_shadow, "0 0 0 8px rgba(66, 153, 225, 0.5)") ])

let ring_offset_2 =
  Style
    ( "ring-offset-2",
      [
        ( Css.Box_shadow,
          "0 0 0 2px rgba(255, 255, 255, 1), 0 0 0 4px rgba(66, 153, 225, 0.5)"
        );
      ] )

let ring_white =
  Style
    ("ring-white", [ (Css.Box_shadow, "0 0 0 3px rgba(255, 255, 255, 0.5)") ])

let isolate = Style ("isolate", [ (Css.Display, "isolate") ])
let overflow_auto = Style ("overflow-auto", [ (Css.Overflow, "auto") ])
let overflow_hidden = Style ("overflow-hidden", [ (Css.Overflow, "hidden") ])
let overflow_visible = Style ("overflow-visible", [ (Css.Overflow, "visible") ])
let overflow_scroll = Style ("overflow-scroll", [ (Css.Overflow, "scroll") ])
let object_contain = Style ("object-contain", [ (Css.Object_fit, "contain") ])
let object_cover = Style ("object-cover", [ (Css.Object_fit, "cover") ])
let object_fill = Style ("object-fill", [ (Css.Object_fit, "fill") ])
let object_none = Style ("object-none", [ (Css.Object_fit, "none") ])

let object_scale_down =
  Style ("object-scale-down", [ (Css.Object_fit, "scale-down") ])

let sr_only =
  Style
    ( "sr-only",
      [
        (Css.Position, "absolute");
        (Css.Width, "1px");
        (Css.Height, "1px");
        (Css.Padding, "0");
        (Css.Margin, "-1px");
        (Css.Overflow, "hidden");
        (Css.Clip, "rect(0, 0, 0, 0)");
        (Css.White_space, "nowrap");
        (Css.Border_width, "0");
      ] )

let not_sr_only =
  Style
    ( "not-sr-only",
      [
        (Css.Position, "static");
        (Css.Width, "auto");
        (Css.Height, "auto");
        (Css.Padding, "0");
        (Css.Margin, "0");
        (Css.Overflow, "visible");
        (Css.Clip, "auto");
        (Css.White_space, "normal");
      ] )

let line_clamp_1 = Style ("line-clamp-1", [ (Css.Webkit_line_clamp, "1") ])
let line_clamp_2 = Style ("line-clamp-2", [ (Css.Webkit_line_clamp, "2") ])
let line_clamp_3 = Style ("line-clamp-3", [ (Css.Webkit_line_clamp, "3") ])
let line_clamp_4 = Style ("line-clamp-4", [ (Css.Webkit_line_clamp, "4") ])
let line_clamp_5 = Style ("line-clamp-5", [ (Css.Webkit_line_clamp, "5") ])
let line_clamp_6 = Style ("line-clamp-6", [ (Css.Webkit_line_clamp, "6") ])

let line_clamp_none =
  Style ("line-clamp-none", [ (Css.Webkit_line_clamp, "none") ])

(* Responsive and state modifiers *)
let focus t = Modified (Focus, t)

let focus_visible =
  Style
    ( "focus-visible",
      [ (Css.Outline, "2px solid transparent"); (Css.Outline_offset, "2px") ] )

let active t = Modified (Active, t)
let disabled t = Modified (Disabled, t)
let group_hover t = Modified (Group_hover, t)
let dark t = Modified (Dark, t)
let sm t = Modified (Responsive "sm", t)
let lg t = Modified (Responsive "lg", t)
let xl t = Modified (Responsive "xl", t)
let xl2 t = Modified (Responsive "2xl", t)

(* More missing values *)
let sm_text_2xl = sm text_2xl
let sm_text_4xl = sm text_4xl
let sm_text_5xl = sm text_5xl
let sm_flex_row = sm flex_row

let sm_transform_none =
  sm (Style ("transform-none", [ (Css.Transform, "none") ]))

let text_gray_300 = text ~shade:300 Gray
let dark_bg_gray_600 = dark (bg ~shade:600 Gray)
let hover_opacity_70 = hover (Style ("opacity-70", [ (Css.Opacity, "0.7") ]))

let bg_gradient_to_b =
  Style
    ( "bg-gradient-to-b",
      [
        ( Css.Background_image,
          "linear-gradient(to bottom, var(--tw-gradient-stops))" );
      ] )

let from_gray_50 = Style ("from-gray-50", [])
let to_white = Style ("to-white", [])

let bg_gradient_to_br =
  Style
    ( "bg-gradient-to-br",
      [
        ( Css.Background_image,
          "linear-gradient(to bottom right, var(--tw-gradient-stops))" );
      ] )

let from_sky_50 = Style ("from-sky-50", [])
let via_blue_50 = Style ("via-blue-50", [])
let to_indigo_50 = Style ("to-indigo-50", [])

let antialiased =
  Style
    ( "antialiased",
      [
        (Css.Webkit_font_smoothing, "antialiased");
        (Css.Moz_osx_font_smoothing, "grayscale");
      ] )

(* Composition operator *)
let ( @> ) _t1 t2 = t2

(* Additional functions needed *)
let aspect_ratio width height =
  let class_name =
    Core.Pp.str
      [ "aspect-["; string_of_float width; "/"; string_of_float height; "]" ]
  in
  (* aspect-ratio isn't widely supported in CSS yet, skip for now *)
  Style (class_name, [])

let clip_path _value =
  (* clip-path is a modern CSS property, skip for now *)
  Style ("clip-path-custom", [])

let w_custom value = Style ("w-custom", [ (Css.Width, value) ])
let transform_gpu = Style ("transform-gpu", [ (Css.Transform, "translateZ(0)") ])
let blur_3xl = Style ("blur-3xl", [ (Css.Filter, "blur(64px)") ])

let from_color color =
  let class_name = "from-" ^ color_name color in
  (* CSS variables for gradients, skip for now *)
  Style (class_name, [])

let to_color color =
  let class_name = "to-" ^ color_name color in
  (* CSS variables for gradients, skip for now *)
  Style (class_name, [])

(* Prose module *)
module Prose = struct
  let prose =
    Style ("prose", [ (Css.Color, "rgb(55 65 81)"); (Css.Max_width, "65ch") ])

  let prose_sm =
    Style
      ( "prose-sm",
        [ (Css.Font_size, "0.875rem"); (Css.Line_height, "1.7142857") ] )

  let prose_base =
    Style ("prose-base", [ (Css.Font_size, "1rem"); (Css.Line_height, "1.75") ])

  let prose_lg =
    Style
      ( "prose-lg",
        [ (Css.Font_size, "1.125rem"); (Css.Line_height, "1.7777778") ] )

  let prose_xl =
    Style ("prose-xl", [ (Css.Font_size, "1.25rem"); (Css.Line_height, "1.8") ])

  let prose_2xl =
    Style
      ( "prose-2xl",
        [ (Css.Font_size, "1.5rem"); (Css.Line_height, "1.6666667") ] )

  let prose_gray = Style ("prose-gray", [ (Css.Color, "rgb(107 114 128)") ])
  let prose_slate = Style ("prose-slate", [ (Css.Color, "rgb(100 116 139)") ])
  let prose_zinc = Style ("prose-zinc", [ (Css.Color, "rgb(113 113 122)") ])

  let prose_neutral =
    Style ("prose-neutral", [ (Css.Color, "rgb(115 115 115)") ])

  let prose_headings_text_sky_900 =
    Style ("prose-headings-text-sky-900", [ (Css.Color, "rgb(12 74 110)") ])

  let prose_stone = Style ("prose-stone", [ (Css.Color, "rgb(120 113 108)") ])
end

(* Class generation functions *)
let rec to_class = function
  | Style (class_name, _) -> class_name
  | Modified (modifier, t) -> (
      let base_class = to_class t in
      match modifier with
      | Hover -> "hover:" ^ base_class
      | Focus -> "focus:" ^ base_class
      | Active -> "active:" ^ base_class
      | Disabled -> "disabled:" ^ base_class
      | Group_hover -> "group-hover:" ^ base_class
      | Dark -> "dark:" ^ base_class
      | Responsive prefix -> prefix ^ ":" ^ base_class)

let to_classes styles = styles |> List.map to_class |> String.concat " "
let to_string t = to_class t
let classes_to_string = to_classes

(* Pretty printing *)
let pp t = to_string t
