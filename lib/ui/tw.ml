(** A type-safe, ergonomic DSL for Tailwind CSS using nominal types. *)

open Css

(** {1 Core Types} *)

type color =
  | Black
  | White
  | Gray
  | Slate
  | Zinc
  | Red
  | Orange
  | Amber
  | Yellow
  | Lime
  | Green
  | Emerald
  | Teal
  | Cyan
  | Sky
  | Blue
  | Indigo
  | Violet
  | Purple
  | Fuchsia
  | Pink
  | Rose

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
  | Peer_hover
  | Peer_focus
  | Peer_checked
  | Group_focus
  | Aria_checked
  | Aria_expanded
  | Aria_selected
  | Aria_disabled

type t =
  | Style of string * property list (* class name, properties *)
  | Modified of modifier * t

(** {1 Helper Functions} *)

(** Convert hex color to rgb format *)
let hex_to_rgb hex =
  let hex = if String.get hex 0 = '#' then String.sub hex 1 6 else hex in
  let r = int_of_string ("0x" ^ String.sub hex 0 2) in
  let g = int_of_string ("0x" ^ String.sub hex 2 2) in
  let b = int_of_string ("0x" ^ String.sub hex 4 2) in
  Core.Pp.str [ string_of_int r; " "; string_of_int g; " "; string_of_int b ]

let color_to_hex color shade =
  match (color, shade) with
  (* Basic colors *)
  | Black, _ -> "#000000"
  | White, _ -> "#ffffff"
  | Gray, 50 -> "#f9fafb"
  | Gray, 100 -> "#f3f4f6"
  | Gray, 200 -> "#e5e7eb"
  | Gray, 300 -> "#d1d5db"
  | Gray, 400 -> "#9ca3af"
  | Gray, 500 -> "#6b7280"
  | Gray, 600 -> "#4b5563"
  | Gray, 700 -> "#374151"
  | Gray, 800 -> "#1f2937"
  | Gray, 900 -> "#111827"
  (* Extended color palette *)
  | Slate, 50 -> "#f8fafc"
  | Slate, 100 -> "#f1f5f9"
  | Slate, 200 -> "#e2e8f0"
  | Slate, 300 -> "#cbd5e1"
  | Slate, 400 -> "#94a3b8"
  | Slate, 500 -> "#64748b"
  | Slate, 600 -> "#475569"
  | Slate, 700 -> "#334155"
  | Slate, 800 -> "#1e293b"
  | Slate, 900 -> "#0f172a"
  | Zinc, 50 -> "#fafafa"
  | Zinc, 100 -> "#f4f4f5"
  | Zinc, 200 -> "#e4e4e7"
  | Zinc, 300 -> "#d4d4d8"
  | Zinc, 400 -> "#a1a1aa"
  | Zinc, 500 -> "#71717a"
  | Zinc, 600 -> "#52525b"
  | Zinc, 700 -> "#3f3f46"
  | Zinc, 800 -> "#27272a"
  | Zinc, 900 -> "#18181b"
  | Red, 50 -> "#fef2f2"
  | Red, 100 -> "#fee2e2"
  | Red, 200 -> "#fecaca"
  | Red, 300 -> "#fca5a5"
  | Red, 400 -> "#f87171"
  | Red, 500 -> "#ef4444"
  | Red, 600 -> "#dc2626"
  | Red, 700 -> "#b91c1c"
  | Red, 800 -> "#991b1b"
  | Red, 900 -> "#7f1d1d"
  | Orange, 50 -> "#fff7ed"
  | Orange, 100 -> "#ffedd5"
  | Orange, 200 -> "#fed7aa"
  | Orange, 300 -> "#fdba74"
  | Orange, 400 -> "#fb923c"
  | Orange, 500 -> "#f97316"
  | Orange, 600 -> "#ea580c"
  | Orange, 700 -> "#c2410c"
  | Orange, 800 -> "#9a3412"
  | Orange, 900 -> "#7c2d12"
  | Amber, 50 -> "#fffbeb"
  | Amber, 100 -> "#fef3c7"
  | Amber, 200 -> "#fde68a"
  | Amber, 300 -> "#fcd34d"
  | Amber, 400 -> "#fbbf24"
  | Amber, 500 -> "#f59e0b"
  | Amber, 600 -> "#d97706"
  | Amber, 700 -> "#b45309"
  | Amber, 800 -> "#92400e"
  | Amber, 900 -> "#78350f"
  | Yellow, 50 -> "#fefce8"
  | Yellow, 100 -> "#fef9c3"
  | Yellow, 200 -> "#fef08a"
  | Yellow, 300 -> "#fde047"
  | Yellow, 400 -> "#facc15"
  | Yellow, 500 -> "#eab308"
  | Yellow, 600 -> "#ca8a04"
  | Yellow, 700 -> "#a16207"
  | Yellow, 800 -> "#854d0e"
  | Yellow, 900 -> "#713f12"
  | Lime, 50 -> "#f7fee7"
  | Lime, 100 -> "#ecfccb"
  | Lime, 200 -> "#d9f99d"
  | Lime, 300 -> "#bef264"
  | Lime, 400 -> "#a3e635"
  | Lime, 500 -> "#84cc16"
  | Lime, 600 -> "#65a30d"
  | Lime, 700 -> "#4d7c0f"
  | Lime, 800 -> "#365314"
  | Lime, 900 -> "#1a2e05"
  | Green, 50 -> "#f0fdf4"
  | Green, 100 -> "#dcfce7"
  | Green, 200 -> "#bbf7d0"
  | Green, 300 -> "#86efac"
  | Green, 400 -> "#4ade80"
  | Green, 500 -> "#22c55e"
  | Green, 600 -> "#16a34a"
  | Green, 700 -> "#15803d"
  | Green, 800 -> "#166534"
  | Green, 900 -> "#14532d"
  | Emerald, 50 -> "#ecfdf5"
  | Emerald, 100 -> "#d1fae5"
  | Emerald, 200 -> "#a7f3d0"
  | Emerald, 300 -> "#6ee7b7"
  | Emerald, 400 -> "#34d399"
  | Emerald, 500 -> "#10b981"
  | Emerald, 600 -> "#059669"
  | Emerald, 700 -> "#047857"
  | Emerald, 800 -> "#065f46"
  | Emerald, 900 -> "#064e3b"
  | Teal, 50 -> "#f0fdfa"
  | Teal, 100 -> "#ccfbf1"
  | Teal, 200 -> "#99f6e4"
  | Teal, 300 -> "#5eead4"
  | Teal, 400 -> "#2dd4bf"
  | Teal, 500 -> "#14b8a6"
  | Teal, 600 -> "#0d9488"
  | Teal, 700 -> "#0f766e"
  | Teal, 800 -> "#115e59"
  | Teal, 900 -> "#134e4a"
  | Cyan, 50 -> "#ecfeff"
  | Cyan, 100 -> "#cffafe"
  | Cyan, 200 -> "#a5f3fc"
  | Cyan, 300 -> "#67e8f9"
  | Cyan, 400 -> "#22d3ee"
  | Cyan, 500 -> "#06b6d4"
  | Cyan, 600 -> "#0891b2"
  | Cyan, 700 -> "#0e7490"
  | Cyan, 800 -> "#155e75"
  | Cyan, 900 -> "#164e63"
  | Sky, 50 -> "#f0f9ff"
  | Sky, 100 -> "#e0f2fe"
  | Sky, 200 -> "#bae6fd"
  | Sky, 300 -> "#7dd3fc"
  | Sky, 400 -> "#38bdf8"
  | Sky, 500 -> "#0ea5e9"
  | Sky, 600 -> "#0284c7"
  | Sky, 700 -> "#0369a1"
  | Sky, 800 -> "#075985"
  | Sky, 900 -> "#0c4a6e"
  | Blue, 50 -> "#eff6ff"
  | Blue, 100 -> "#dbeafe"
  | Blue, 200 -> "#bfdbfe"
  | Blue, 300 -> "#93c5fd"
  | Blue, 400 -> "#60a5fa"
  | Blue, 500 -> "#3b82f6"
  | Blue, 600 -> "#2563eb"
  | Blue, 700 -> "#1d4ed8"
  | Blue, 800 -> "#1e40af"
  | Blue, 900 -> "#1e3a8a"
  | Indigo, 50 -> "#eef2ff"
  | Indigo, 100 -> "#e0e7ff"
  | Indigo, 200 -> "#c7d2fe"
  | Indigo, 300 -> "#a5b4fc"
  | Indigo, 400 -> "#818cf8"
  | Indigo, 500 -> "#6366f1"
  | Indigo, 600 -> "#4f46e5"
  | Indigo, 700 -> "#4338ca"
  | Indigo, 800 -> "#3730a3"
  | Indigo, 900 -> "#312e81"
  | Violet, 50 -> "#f5f3ff"
  | Violet, 100 -> "#ede9fe"
  | Violet, 200 -> "#ddd6fe"
  | Violet, 300 -> "#c4b5fd"
  | Violet, 400 -> "#a78bfa"
  | Violet, 500 -> "#8b5cf6"
  | Violet, 600 -> "#7c3aed"
  | Violet, 700 -> "#6d28d9"
  | Violet, 800 -> "#5b21b6"
  | Violet, 900 -> "#4c1d95"
  | Purple, 50 -> "#faf5ff"
  | Purple, 100 -> "#f3e8ff"
  | Purple, 200 -> "#e9d5ff"
  | Purple, 300 -> "#d8b4fe"
  | Purple, 400 -> "#c084fc"
  | Purple, 500 -> "#a855f7"
  | Purple, 600 -> "#9333ea"
  | Purple, 700 -> "#7e22ce"
  | Purple, 800 -> "#6b21a8"
  | Purple, 900 -> "#581c87"
  | Fuchsia, 50 -> "#fdf4ff"
  | Fuchsia, 100 -> "#fae8ff"
  | Fuchsia, 200 -> "#f5d0fe"
  | Fuchsia, 300 -> "#f0abfc"
  | Fuchsia, 400 -> "#e879f9"
  | Fuchsia, 500 -> "#d946ef"
  | Fuchsia, 600 -> "#c026d3"
  | Fuchsia, 700 -> "#a21caf"
  | Fuchsia, 800 -> "#86198f"
  | Fuchsia, 900 -> "#701a75"
  | Pink, 50 -> "#fdf2f8"
  | Pink, 100 -> "#fce7f3"
  | Pink, 200 -> "#fbcfe8"
  | Pink, 300 -> "#f9a8d4"
  | Pink, 400 -> "#f472b6"
  | Pink, 500 -> "#ec4899"
  | Pink, 600 -> "#db2777"
  | Pink, 700 -> "#be185d"
  | Pink, 800 -> "#9d174d"
  | Pink, 900 -> "#831843"
  | Rose, 50 -> "#fff1f2"
  | Rose, 100 -> "#ffe4e6"
  | Rose, 200 -> "#fecdd3"
  | Rose, 300 -> "#fda4af"
  | Rose, 400 -> "#fb7185"
  | Rose, 500 -> "#f43f5e"
  | Rose, 600 -> "#e11d48"
  | Rose, 700 -> "#be123c"
  | Rose, 800 -> "#9f1239"
  | Rose, 900 -> "#881337"
  | color, shade ->
      let color_name =
        match color with
        | Black -> "Black"
        | White -> "White"
        | Gray -> "Gray"
        | Slate -> "Slate"
        | Zinc -> "Zinc"
        | Red -> "Red"
        | Orange -> "Orange"
        | Amber -> "Amber"
        | Yellow -> "Yellow"
        | Lime -> "Lime"
        | Green -> "Green"
        | Emerald -> "Emerald"
        | Teal -> "Teal"
        | Cyan -> "Cyan"
        | Sky -> "Sky"
        | Blue -> "Blue"
        | Indigo -> "Indigo"
        | Violet -> "Violet"
        | Purple -> "Purple"
        | Fuchsia -> "Fuchsia"
        | Pink -> "Pink"
        | Rose -> "Rose"
      in
      let err_unknown_color color shade =
        Core.Pp.str
          [ "Unknown color combination: "; color; " "; string_of_int shade ]
      in
      failwith (err_unknown_color color_name shade)

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

(** {1 Colors} *)

let color_name = function
  | Black -> "black"
  | White -> "white"
  | Gray -> "gray"
  | Slate -> "slate"
  | Zinc -> "zinc"
  | Red -> "red"
  | Orange -> "orange"
  | Amber -> "amber"
  | Yellow -> "yellow"
  | Lime -> "lime"
  | Green -> "green"
  | Emerald -> "emerald"
  | Teal -> "teal"
  | Cyan -> "cyan"
  | Sky -> "sky"
  | Blue -> "blue"
  | Indigo -> "indigo"
  | Violet -> "violet"
  | Purple -> "purple"
  | Fuchsia -> "fuchsia"
  | Pink -> "pink"
  | Rose -> "rose"

let bg ?(shade = 500) color =
  let class_name =
    match color with
    | Black | White -> Core.Pp.str [ "bg-"; color_name color ]
    | _ -> Core.Pp.str [ "bg-"; color_name color; "-"; string_of_int shade ]
  in
  let hex = color_to_hex color shade in
  let rgb = hex_to_rgb hex in
  Style
    ( class_name,
      [
        (Custom "--tw-bg-opacity", "1");
        ( Background_color,
          Core.Pp.str [ "rgb("; rgb; " / var(--tw-bg-opacity))" ] );
      ] )

let bg_transparent =
  Style ("bg-transparent", [ (Background_color, "transparent") ])

let bg_current = Style ("bg-current", [ (Background_color, "currentColor") ])

let text ?(shade = 500) color =
  let class_name =
    match color with
    | Black | White -> Core.Pp.str [ "text-"; color_name color ]
    | _ -> Core.Pp.str [ "text-"; color_name color; "-"; string_of_int shade ]
  in
  let hex = color_to_hex color shade in
  let rgb = hex_to_rgb hex in
  Style
    ( class_name,
      [
        (Custom "--tw-text-opacity", "1");
        (Color, Core.Pp.str [ "rgb("; rgb; " / var(--tw-text-opacity))" ]);
      ] )

let text_transparent = Style ("text-transparent", [ (Color, "transparent") ])
let text_current = Style ("text-current", [ (Color, "currentColor") ])

let border_color ?(shade = 500) color =
  let class_name =
    match color with
    | Black | White -> Core.Pp.str [ "border-"; color_name color ]
    | _ -> Core.Pp.str [ "border-"; color_name color; "-"; string_of_int shade ]
  in
  let hex = color_to_hex color shade in
  let rgb = hex_to_rgb hex in
  Style
    ( class_name,
      [
        (Custom "--tw-border-opacity", "1");
        ( Border_color,
          Core.Pp.str [ "rgb("; rgb; " / var(--tw-border-opacity))" ] );
      ] )

let border_transparent =
  Style ("border-transparent", [ (Border_color, "transparent") ])

let border_current = Style ("border-current", [ (Border_color, "currentColor") ])

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

(** Format float for CSS - ensures leading zero and removes trailing dot *)
let css_float f =
  let s = string_of_float f in
  let s = if String.starts_with ~prefix:"." s then "0" ^ s else s in
  if String.ends_with ~suffix:"." s then String.sub s 0 (String.length s - 1)
  else s

let spacing_to_string : spacing -> string = function
  | Int n ->
      (* Tailwind uses 0.25rem (4px) as base unit, so n * 0.25rem *)
      if n = 0 then "0"
      else
        let rem_value = float_of_int n *. 0.25 in
        Core.Pp.str [ css_float rem_value; "rem" ]
  | Px -> "1px"
  | Full -> "100%"
  | Val f -> if f = 0.0 then "0" else Core.Pp.str [ css_float f; "rem" ]

let margin_to_string = function
  | Auto -> "auto"
  | Int n ->
      (* Tailwind uses 0.25rem (4px) as base unit, so n * 0.25rem *)
      if n = 0 then "0"
      else
        let rem_value = float_of_int n *. 0.25 in
        Core.Pp.str [ css_float rem_value; "rem" ]
  | Px -> "1px"
  | Full -> "100%"
  | Val f -> if f = 0.0 then "0" else Core.Pp.str [ css_float f; "rem" ]

let size_to_string = function
  | Screen -> "100vh"
  | Int n ->
      (* Tailwind uses 0.25rem (4px) as base unit, so n * 0.25rem *)
      if n = 0 then "0"
      else
        let rem_value = float_of_int n *. 0.25 in
        Core.Pp.str [ css_float rem_value; "rem" ]
  | Px -> "1px"
  | Full -> "100%"
  | Val f -> if f = 0.0 then "0" else Core.Pp.str [ css_float f; "rem" ]

(** {1 Spacing} *)

let p s =
  let class_name = "p-" ^ spacing_class_suffix s in
  Style (class_name, [ (Padding, spacing_to_string s) ])

let px s =
  let v = spacing_to_string s in
  let class_name = "px-" ^ spacing_class_suffix s in
  Style (class_name, [ (Padding_left, v); (Padding_right, v) ])

let py s =
  let v = spacing_to_string s in
  let class_name = "py-" ^ spacing_class_suffix s in
  Style (class_name, [ (Padding_bottom, v); (Padding_top, v) ])

let pt s =
  let class_name = "pt-" ^ spacing_class_suffix s in
  Style (class_name, [ (Padding_top, spacing_to_string s) ])

let pr s =
  let class_name = "pr-" ^ spacing_class_suffix s in
  Style (class_name, [ (Padding_right, spacing_to_string s) ])

let pb s =
  let class_name = "pb-" ^ spacing_class_suffix s in
  Style (class_name, [ (Padding_bottom, spacing_to_string s) ])

let pl s =
  let class_name = "pl-" ^ spacing_class_suffix s in
  Style (class_name, [ (Padding_left, spacing_to_string s) ])

let m m =
  let class_name = "m-" ^ margin_class_suffix m in
  Style (class_name, [ (Margin, margin_to_string m) ])

let mx m =
  let v = margin_to_string m in
  let class_name = "mx-" ^ margin_class_suffix m in
  Style (class_name, [ (Margin_left, v); (Margin_right, v) ])

let my m =
  let v = margin_to_string m in
  let class_name = "my-" ^ margin_class_suffix m in
  Style (class_name, [ (Margin_bottom, v); (Margin_top, v) ])

let mt m =
  let class_name = "mt-" ^ margin_class_suffix m in
  Style (class_name, [ (Margin_top, margin_to_string m) ])

let mr m =
  let class_name = "mr-" ^ margin_class_suffix m in
  Style (class_name, [ (Margin_right, margin_to_string m) ])

let mb m =
  let class_name = "mb-" ^ margin_class_suffix m in
  Style (class_name, [ (Margin_bottom, margin_to_string m) ])

let ml m =
  let class_name = "ml-" ^ margin_class_suffix m in
  Style (class_name, [ (Margin_left, margin_to_string m) ])

let gap s =
  let class_name = "gap-" ^ spacing_class_suffix s in
  Style (class_name, [ (Gap, spacing_to_string s) ])

let gap_x s =
  let class_name = "gap-x-" ^ spacing_class_suffix s in
  Style (class_name, [ (Column_gap, spacing_to_string s) ])

let gap_y s =
  let class_name = "gap-y-" ^ spacing_class_suffix s in
  Style (class_name, [ (Row_gap, spacing_to_string s) ])

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

(** {1 Sizing} *)

let w s =
  let class_name = "w-" ^ size_class_suffix s in
  Style (class_name, [ (Width, size_to_string s) ])

let w_auto = Style ("w-auto", [ (Width, "auto") ])
let w_full = Style ("w-full", [ (Width, "100%") ])

let h s =
  let class_name = "h-" ^ size_class_suffix s in
  match s with
  | Screen -> Style (class_name, [ (Height, "100vh") ])
  | _ -> Style (class_name, [ (Height, size_to_string s) ])

let h_auto = Style ("h-auto", [ (Height, "auto") ])
let h_full = Style ("h-full", [ (Height, "100%") ])

let min_w s =
  let class_name = "min-w-" ^ spacing_class_suffix s in
  Style (class_name, [ (Min_width, spacing_to_string s) ])

let min_h s =
  let class_name = "min-h-" ^ size_class_suffix s in
  match s with
  | Screen -> Style (class_name, [ (Min_height, "100vh") ])
  | _ -> Style (class_name, [ (Min_height, size_to_string s) ])

let min_h_screen = min_h Screen

let max_w s =
  let class_name = "max-w-" ^ spacing_class_suffix s in
  Style (class_name, [ (Max_width, spacing_to_string s) ])

let max_w_7xl = Style ("max-w-7xl", [ (Max_width, "80rem") ])

(** {1 Typography} *)

let text_xs =
  Style ("text-xs", [ (Font_size, "0.75rem"); (Line_height, "1rem") ])

let text_sm =
  Style ("text-sm", [ (Font_size, "0.875rem"); (Line_height, "1.25rem") ])

let text_xl =
  Style ("text-xl", [ (Font_size, "1.25rem"); (Line_height, "1.75rem") ])

let text_2xl =
  Style ("text-2xl", [ (Font_size, "1.5rem"); (Line_height, "2rem") ])

let font_medium = Style ("font-medium", [ (Font_weight, "500") ])
let font_bold = Style ("font-bold", [ (Font_weight, "700") ])
let text_center = Style ("text-center", [ (Text_align, "center") ])

(** {1 Layout} *)

let block = Style ("block", [ (Display, "block") ])
let inline = Style ("inline", [ (Display, "inline") ])
let inline_block = Style ("inline-block", [ (Display, "inline-block") ])
let hidden = Style ("hidden", [ (Display, "none") ])

(** {1 Flexbox} *)

let flex = Style ("flex", [ (Display, "flex") ])
let flex_shrink_0 = Style ("flex-shrink-0", [ (Flex_shrink, "0") ])
let flex_col = Style ("flex-col", [ (Flex_direction, "column") ])
let flex_row = Style ("flex-row", [ (Flex_direction, "row") ])
let flex_wrap = Style ("flex-wrap", [ (Flex_wrap, "wrap") ])

let flex_row_reverse =
  Style ("flex-row-reverse", [ (Flex_direction, "row-reverse") ])

let flex_col_reverse =
  Style ("flex-col-reverse", [ (Flex_direction, "column-reverse") ])

let flex_wrap_reverse =
  Style ("flex-wrap-reverse", [ (Flex_wrap, "wrap-reverse") ])

let flex_nowrap = Style ("flex-nowrap", [ (Flex_wrap, "nowrap") ])
let flex_1 = Style ("flex-1", [ (Flex, "1 1 0%") ])
let flex_auto = Style ("flex-auto", [ (Flex, "1 1 auto") ])
let flex_initial = Style ("flex-initial", [ (Flex, "0 1 auto") ])
let flex_none = Style ("flex-none", [ (Flex, "none") ])
let flex_grow = Style ("flex-grow", [ (Flex_grow, "1") ])
let flex_grow_0 = Style ("flex-grow-0", [ (Flex_grow, "0") ])
let flex_shrink = Style ("flex-shrink", [ (Flex_shrink, "1") ])

(* center *)

let items_center = Style ("items-center", [ (Align_items, "center") ])

let justify_between =
  Style ("justify-between", [ (Justify_content, "space-between") ])

(** {1 Positioning} *)

let relative = Style ("relative", [ (Position, "relative") ])
let absolute = Style ("absolute", [ (Position, "absolute") ])
let fixed = Style ("fixed", [ (Position, "fixed") ])
let sticky = Style ("sticky", [ (Position, "sticky") ])

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
let opacity_50 = Style ("opacity-50", [ (Opacity, "0.5") ])

(** {1 CSS Generation} *)

let rec to_css_properties = function
  | Style (_class_name, props) -> props
  | Modified (_modifier, t) -> to_css_properties t

let to_css_rule ~selector styles =
  let properties = styles |> List.concat_map to_css_properties in
  rule ~selector properties

let to_stylesheet selector_styles =
  let rules =
    selector_styles
    |> List.map (fun (selector, styles) -> to_css_rule ~selector styles)
  in
  stylesheet rules

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
            | Group_focus -> (".group:focus " ^ selector, props)
            | Peer_hover -> (".peer:hover ~ " ^ selector, props)
            | Peer_focus -> (".peer:focus ~ " ^ selector, props)
            | Peer_checked -> (".peer:checked ~ " ^ selector, props)
            | Aria_checked -> (selector ^ "[aria-checked=\"true\"]", props)
            | Aria_expanded -> (selector ^ "[aria-expanded=\"true\"]", props)
            | Aria_selected -> (selector ^ "[aria-selected=\"true\"]", props)
            | Aria_disabled -> (selector ^ "[aria-disabled=\"true\"]", props)
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
    rule ~selector:"*"
      [ (Margin, "0"); (Padding, "0"); (Box_sizing, "border-box") ];
    rule ~selector:"body"
      [
        (Font_size, "16px");
        (Line_height, "1.5");
        (Color, "#374151");
        ( Font_family,
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
      (fun (selector, props) -> rule ~selector (deduplicate_properties props))
      all_rules
  in
  stylesheet (reset_rules @ rules)

let color_to_string = function
  | Black -> "black"
  | White -> "white"
  | Gray -> "gray"
  | Slate -> "slate"
  | Zinc -> "zinc"
  | Red -> "red"
  | Orange -> "orange"
  | Amber -> "amber"
  | Yellow -> "yellow"
  | Lime -> "lime"
  | Green -> "green"
  | Emerald -> "emerald"
  | Teal -> "teal"
  | Cyan -> "cyan"
  | Sky -> "sky"
  | Blue -> "blue"
  | Indigo -> "indigo"
  | Violet -> "violet"
  | Purple -> "purple"
  | Fuchsia -> "fuchsia"
  | Pink -> "pink"
  | Rose -> "rose"

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
  Style (class_name, [ (Margin_top, "-" ^ spacing_to_string s) ])

let neg_mr s =
  let class_name = "-mr-" ^ spacing_class_suffix s in
  Style (class_name, [ (Margin_right, "-" ^ spacing_to_string s) ])

let neg_mb s =
  let class_name = "-mb-" ^ spacing_class_suffix s in
  Style (class_name, [ (Margin_bottom, "-" ^ spacing_to_string s) ])

let neg_ml s =
  let class_name = "-ml-" ^ spacing_class_suffix s in
  Style (class_name, [ (Margin_left, "-" ^ spacing_to_string s) ])

let neg_mt_56 = neg_mt (Int 56)
let w_min = Style ("w-min", [ (Width, "min-content") ])
let w_max = Style ("w-max", [ (Width, "max-content") ])
let w_fit = Style ("w-fit", [ (Width, "fit-content") ])
let h_min = Style ("h-min", [ (Height, "min-content") ])
let h_max = Style ("h-max", [ (Height, "max-content") ])
let h_fit = Style ("h-fit", [ (Height, "fit-content") ])
let h_10 = h (Int 10)
let h_12 = h (Int 12)
let min_w_min = Style ("min-w-min", [ (Min_width, "min-content") ])
let min_w_max = Style ("min-w-max", [ (Min_width, "max-content") ])
let min_w_fit = Style ("min-w-fit", [ (Min_width, "fit-content") ])
let min_w_full = Style ("min-w-full", [ (Min_width, "100%") ])
let min_h_min = Style ("min-h-min", [ (Min_height, "min-content") ])
let min_h_max = Style ("min-h-max", [ (Min_height, "max-content") ])
let min_h_fit = Style ("min-h-fit", [ (Min_height, "fit-content") ])
let max_w_none = Style ("max-w-none", [ (Max_width, "none") ])
let max_w_full = Style ("max-w-full", [ (Max_width, "100%") ])
let max_w_xs = Style ("max-w-xs", [ (Max_width, "20rem") ])
let max_w_sm = Style ("max-w-sm", [ (Max_width, "24rem") ])
let max_w_md = Style ("max-w-md", [ (Max_width, "28rem") ])
let max_w_lg = Style ("max-w-lg", [ (Max_width, "32rem") ])
let max_w_xl = Style ("max-w-xl", [ (Max_width, "36rem") ])
let max_w_2xl = Style ("max-w-2xl", [ (Max_width, "42rem") ])
let max_w_3xl = Style ("max-w-3xl", [ (Max_width, "48rem") ])
let max_w_4xl = Style ("max-w-4xl", [ (Max_width, "56rem") ])
let max_w_5xl = Style ("max-w-5xl", [ (Max_width, "64rem") ])
let max_w_6xl = Style ("max-w-6xl", [ (Max_width, "72rem") ])

let max_h s =
  let class_name = "max-h-" ^ size_class_suffix s in
  match s with
  | Screen -> Style (class_name, [ (Max_height, "100vh") ])
  | _ -> Style (class_name, [ (Max_height, size_to_string s) ])

let max_h_none = Style ("max-h-none", [ (Max_height, "none") ])

let text_base =
  Style ("text-base", [ (Font_size, "1rem"); (Line_height, "1.5rem") ])

let text_lg =
  Style ("text-lg", [ (Font_size, "1.125rem"); (Line_height, "1.75rem") ])

let text_3xl =
  Style ("text-3xl", [ (Font_size, "1.875rem"); (Line_height, "2.25rem") ])

let text_4xl =
  Style ("text-4xl", [ (Font_size, "2.25rem"); (Line_height, "2.5rem") ])

let text_5xl = Style ("text-5xl", [ (Font_size, "3rem"); (Line_height, "1") ])
let font_thin = Style ("font-thin", [ (Font_weight, "100") ])
let font_light = Style ("font-light", [ (Font_weight, "300") ])
let font_normal = Style ("font-normal", [ (Font_weight, "400") ])
let font_semibold = Style ("font-semibold", [ (Font_weight, "600") ])
let font_extrabold = Style ("font-extrabold", [ (Font_weight, "800") ])
let font_black = Style ("font-black", [ (Font_weight, "900") ])
let italic = Style ("italic", [ (Font_style, "italic") ])
let not_italic = Style ("not-italic", [ (Font_style, "normal") ])
let underline = Style ("underline", [ (Text_decoration, "underline") ])
let line_through = Style ("line-through", [ (Text_decoration, "line-through") ])
let no_underline = Style ("no-underline", [ (Text_decoration, "none") ])
let text_left = Style ("text-left", [ (Text_align, "left") ])
let text_right = Style ("text-right", [ (Text_align, "right") ])
let text_justify = Style ("text-justify", [ (Text_align, "justify") ])
let leading_none = Style ("leading-none", [ (Line_height, "1") ])
let leading_tight = Style ("leading-tight", [ (Line_height, "1.25") ])
let leading_snug = Style ("leading-snug", [ (Line_height, "1.375") ])
let leading_normal = Style ("leading-normal", [ (Line_height, "1.5") ])
let leading_relaxed = Style ("leading-relaxed", [ (Line_height, "1.625") ])
let leading_loose = Style ("leading-loose", [ (Line_height, "2") ])
let leading_6 = Style ("leading-6", [ (Line_height, "1.5rem") ])

let tracking_tighter =
  Style ("tracking-tighter", [ (Letter_spacing, "-0.05em") ])

let tracking_tight = Style ("tracking-tight", [ (Letter_spacing, "-0.025em") ])
let tracking_normal = Style ("tracking-normal", [ (Letter_spacing, "0") ])
let tracking_wide = Style ("tracking-wide", [ (Letter_spacing, "0.025em") ])
let tracking_wider = Style ("tracking-wider", [ (Letter_spacing, "0.05em") ])
let tracking_widest = Style ("tracking-widest", [ (Letter_spacing, "0.1em") ])
let whitespace_normal = Style ("whitespace-normal", [ (White_space, "normal") ])
let whitespace_nowrap = Style ("whitespace-nowrap", [ (White_space, "nowrap") ])
let whitespace_pre = Style ("whitespace-pre", [ (White_space, "pre") ])

let whitespace_pre_line =
  Style ("whitespace-pre-line", [ (White_space, "pre-line") ])

let whitespace_pre_wrap =
  Style ("whitespace-pre-wrap", [ (White_space, "pre-wrap") ])

let inline_flex = Style ("inline-flex", [ (Display, "inline-flex") ])
let grid = Style ("grid", [ (Display, "grid") ])
let inline_grid = Style ("inline-grid", [ (Display, "inline-grid") ])
let items_start = Style ("items-start", [ (Align_items, "flex-start") ])
let items_end = Style ("items-end", [ (Align_items, "flex-end") ])
let items_baseline = Style ("items-baseline", [ (Align_items, "baseline") ])
let items_stretch = Style ("items-stretch", [ (Align_items, "stretch") ])
let justify_start = Style ("justify-start", [ (Justify_content, "flex-start") ])
let justify_end = Style ("justify-end", [ (Justify_content, "flex-end") ])
let justify_center = Style ("justify-center", [ (Justify_content, "center") ])

let justify_around =
  Style ("justify-around", [ (Justify_content, "space-around") ])

let justify_evenly =
  Style ("justify-evenly", [ (Justify_content, "space-evenly") ])

let grid_cols n =
  let class_name = "grid-cols-" ^ string_of_int n in
  Style
    ( class_name,
      [
        ( Grid_template_columns,
          "repeat(" ^ string_of_int n ^ ", minmax(0, 1fr))" );
      ] )

let grid_rows n =
  let class_name = "grid-rows-" ^ string_of_int n in
  Style
    ( class_name,
      [
        (Grid_template_rows, "repeat(" ^ string_of_int n ^ ", minmax(0, 1fr))");
      ] )

(* Grid column instances *)
let grid_cols_1 = grid_cols 1
let grid_cols_2 = grid_cols 2
let grid_cols_3 = grid_cols 3
let grid_cols_4 = grid_cols 4
let grid_cols_5 = grid_cols 5
let grid_cols_6 = grid_cols 6
let grid_cols_7 = grid_cols 7
let grid_cols_8 = grid_cols 8
let grid_cols_9 = grid_cols 9
let grid_cols_10 = grid_cols 10
let grid_cols_11 = grid_cols 11
let grid_cols_12 = grid_cols 12

(* Grid row instances *)
let grid_rows_1 = grid_rows 1
let grid_rows_2 = grid_rows 2
let grid_rows_3 = grid_rows 3
let grid_rows_4 = grid_rows 4
let grid_rows_5 = grid_rows 5
let grid_rows_6 = grid_rows 6
let static = Style ("static", [ (Position, "static") ])

let inset_0 =
  Style
    ("inset-0", [ (Top, "0"); (Right, "0"); (Css.Bottom, "0"); (Css.Left, "0") ])

let inset_x_0 = Style ("inset-x-0", [ (Left, "0"); (Right, "0") ])
let inset_y_0 = Style ("inset-y-0", [ (Bottom, "0"); (Top, "0") ])

let top n =
  let class_name = "top-" ^ string_of_int n in
  Style (class_name, [ (Top, spacing_to_rem n) ])

let right n =
  let class_name = "right-" ^ string_of_int n in
  Style (class_name, [ (Right, spacing_to_rem n) ])

let bottom n =
  let class_name = "bottom-" ^ string_of_int n in
  Style (class_name, [ (Bottom, spacing_to_rem n) ])

let left n =
  let class_name = "left-" ^ string_of_int n in
  Style (class_name, [ (Left, spacing_to_rem n) ])

let z n =
  let class_name = "z-" ^ string_of_int n in
  Style (class_name, [ (Z_index, string_of_int n) ])

let z_10 = z 10
let border = Style ("border", [ (Border_width, "1px") ])
let border_t = Style ("border-t", [ (Border_top_width, "1px") ])
let border_r = Style ("border-r", [ (Border_right_width, "1px") ])
let border_b = Style ("border-b", [ (Border_bottom_width, "1px") ])
let border_l = Style ("border-l", [ (Border_left_width, "1px") ])
let border_0 = Style ("border-0", [ (Border_width, "0") ])
let border_2 = Style ("border-2", [ (Border_width, "2px") ])
let border_4 = Style ("border-4", [ (Border_width, "4px") ])
let border_8 = Style ("border-8", [ (Border_width, "8px") ])

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
  Style (class_name, [ (Border_radius, rounded_value r) ])

let rounded_none = rounded None
let rounded_sm = rounded Sm
let rounded_lg = rounded Lg
let rounded_xl = rounded Xl
let rounded_2xl = rounded Xl_2
let rounded_3xl = rounded Xl_3
let rounded_full = rounded Full

let shadow_value : shadow -> string = function
  | None -> "0 0 #0000"
  | Sm -> "0 1px 2px 0 #0000000d" (* rgba(0,0,0,0.05) = #0000000d *)
  | Md -> "0 4px 6px -1px #0000001a,0 2px 4px -2px #0000000f" (* 0.1 and 0.06 *)
  | Lg ->
      "0 10px 15px -3px #0000001a,0 4px 6px -4px #0000000d" (* 0.1 and 0.05 *)
  | Xl ->
      "0 20px 25px -5px #0000001a,0 8px 10px -6px #0000000a" (* 0.1 and 0.04 *)
  | Xl_2 -> "0 25px 50px -12px #00000040" (* 0.25 *)
  | Inner -> "inset 0 2px 4px 0 #0000000f" (* 0.06 *)

let shadow_class_suffix : shadow -> string = function
  | None -> "none"
  | Sm -> "sm"
  | Md -> "md"
  | Lg -> "lg"
  | Xl -> "xl"
  | Xl_2 -> "2xl"
  | Inner -> "inner"

let shadow_colored_value : shadow -> string = function
  | None -> "0 0 #0000"
  | Sm -> "0 1px 2px 0 var(--tw-shadow-color)"
  | Md ->
      "0 4px 6px -1px var(--tw-shadow-color),0 2px 4px -2px \
       var(--tw-shadow-color)"
  | Lg ->
      "0 10px 15px -3px var(--tw-shadow-color),0 4px 6px -4px \
       var(--tw-shadow-color)"
  | Xl ->
      "0 20px 25px -5px var(--tw-shadow-color),0 8px 10px -6px \
       var(--tw-shadow-color)"
  | Xl_2 -> "0 25px 50px -12px var(--tw-shadow-color)"
  | Inner -> "inset 0 2px 4px 0 var(--tw-shadow-color)"

let shadow s =
  let class_name = "shadow-" ^ shadow_class_suffix s in
  (* For modern Tailwind, shadows use CSS custom properties *)
  (* Note: Tailwind will automatically merge the box-shadow property for classes that share it *)
  let custom_props =
    [
      (Custom "--tw-shadow", shadow_value s);
      (Custom "--tw-shadow-colored", shadow_colored_value s);
    ]
  in
  let box_shadow_prop =
    ( Box_shadow,
      "var(--tw-ring-offset-shadow,0 0 #0000),var(--tw-ring-shadow,0 0 \
       #0000),var(--tw-shadow)" )
  in
  Style (class_name, custom_props @ [ box_shadow_prop ])

let shadow_sm = shadow Sm
let shadow_md = shadow Md
let shadow_lg = shadow Lg
let shadow_xl = shadow Xl
let shadow_2xl = shadow Xl_2
let shadow_inner = shadow Inner
let shadow_none = shadow None

let opacity n =
  let class_name = "opacity-" ^ string_of_int n in
  let value =
    if n = 0 then "0"
    else if n = 100 then "1"
    else string_of_float (float_of_int n /. 100.0)
  in
  Style (class_name, [ (Opacity, value) ])

let opacity_10 = opacity 10
let opacity_25 = Style ("opacity-25", [ (Opacity, "0.25") ])
let opacity_30 = opacity 30
let transition_none = Style ("transition-none", [ (Transition, "none") ])

let transition_all =
  Style
    ( "transition-all",
      [ (Transition, "all 150ms cubic-bezier(0.4, 0, 0.2, 1)") ] )

let transition_colors =
  Style
    ( "transition-colors",
      [
        ( Transition,
          "background-color, border-color, color, fill, stroke 150ms \
           cubic-bezier(0.4, 0, 0.2, 1)" );
      ] )

let transition_opacity =
  Style
    ( "transition-opacity",
      [ (Transition, "opacity 150ms cubic-bezier(0.4, 0, 0.2, 1)") ] )

let transition_shadow =
  Style
    ( "transition-shadow",
      [ (Transition, "box-shadow 150ms cubic-bezier(0.4, 0, 0.2, 1)") ] )

let transition_transform =
  Style
    ( "transition-transform",
      [ (Transition, "transform 150ms cubic-bezier(0.4, 0, 0.2, 1)") ] )

let scale n =
  let class_name = "scale-" ^ string_of_int n in
  Style
    ( class_name,
      [
        (Transform, "scale(" ^ string_of_float (float_of_int n /. 100.0) ^ ")");
      ] )

let scale_150 = scale 150

let rotate n =
  let class_name = "rotate-" ^ string_of_int n in
  Style (class_name, [ (Transform, "rotate(" ^ string_of_int n ^ "deg)") ])

let translate_x n =
  let class_name = "translate-x-" ^ string_of_int n in
  Style (class_name, [ (Transform, "translateX(" ^ spacing_to_rem n ^ ")") ])

let translate_y n =
  let class_name = "translate-y-" ^ string_of_int n in
  Style (class_name, [ (Transform, "translateY(" ^ spacing_to_rem n ^ ")") ])

let cursor_auto = Style ("cursor-auto", [ (Cursor, "auto") ])
let cursor_default = Style ("cursor-default", [ (Cursor, "default") ])
let cursor_pointer = Style ("cursor-pointer", [ (Cursor, "pointer") ])
let cursor_wait = Style ("cursor-wait", [ (Cursor, "wait") ])
let cursor_move = Style ("cursor-move", [ (Cursor, "move") ])

let cursor_not_allowed =
  Style ("cursor-not-allowed", [ (Cursor, "not-allowed") ])

let select_none = Style ("select-none", [ (User_select, "none") ])
let select_text = Style ("select-text", [ (User_select, "text") ])
let select_all = Style ("select-all", [ (User_select, "all") ])
let select_auto = Style ("select-auto", [ (User_select, "auto") ])

let pointer_events_none =
  Style ("pointer-events-none", [ (Pointer_events, "none") ])

let pointer_events_auto =
  Style ("pointer-events-auto", [ (Pointer_events, "auto") ])

let outline_none = Style ("outline-none", [ (Outline, "none") ])
let ring = Style ("ring", [ (Box_shadow, "0 0 0 3px rgba(66, 153, 225, 0.5)") ])
let ring_0 = Style ("ring-0", [ (Box_shadow, "none") ])

let ring_1 =
  Style ("ring-1", [ (Box_shadow, "0 0 0 1px rgba(66, 153, 225, 0.5)") ])

let ring_2 =
  Style ("ring-2", [ (Box_shadow, "0 0 0 2px rgba(66, 153, 225, 0.5)") ])

let ring_4 =
  Style ("ring-4", [ (Box_shadow, "0 0 0 4px rgba(66, 153, 225, 0.5)") ])

let ring_8 =
  Style ("ring-8", [ (Box_shadow, "0 0 0 8px rgba(66, 153, 225, 0.5)") ])

let ring_offset_2 =
  Style
    ( "ring-offset-2",
      [
        ( Box_shadow,
          "0 0 0 2px rgba(255, 255, 255, 1), 0 0 0 4px rgba(66, 153, 225, 0.5)"
        );
      ] )

let ring_white =
  Style ("ring-white", [ (Box_shadow, "0 0 0 3px rgba(255, 255, 255, 0.5)") ])

let isolate = Style ("isolate", [ (Display, "isolate") ])
let overflow_auto = Style ("overflow-auto", [ (Overflow, "auto") ])
let overflow_hidden = Style ("overflow-hidden", [ (Overflow, "hidden") ])
let overflow_visible = Style ("overflow-visible", [ (Overflow, "visible") ])
let overflow_scroll = Style ("overflow-scroll", [ (Overflow, "scroll") ])

(* Overflow variants *)
let overflow_x_auto = Style ("overflow-x-auto", [ (Overflow_x, "auto") ])
let overflow_x_hidden = Style ("overflow-x-hidden", [ (Overflow_x, "hidden") ])

let overflow_x_visible =
  Style ("overflow-x-visible", [ (Overflow_x, "visible") ])

let overflow_x_scroll = Style ("overflow-x-scroll", [ (Overflow_x, "scroll") ])
let overflow_y_auto = Style ("overflow-y-auto", [ (Overflow_y, "auto") ])
let overflow_y_hidden = Style ("overflow-y-hidden", [ (Overflow_y, "hidden") ])

let overflow_y_visible =
  Style ("overflow-y-visible", [ (Overflow_y, "visible") ])

let overflow_y_scroll = Style ("overflow-y-scroll", [ (Overflow_y, "scroll") ])

(* Scroll snap utilities *)
let snap_none = Style ("snap-none", [ (Scroll_snap_type, "none") ])

let snap_x =
  Style ("snap-x", [ (Scroll_snap_type, "x var(--tw-scroll-snap-strictness)") ])

let snap_y =
  Style ("snap-y", [ (Scroll_snap_type, "y var(--tw-scroll-snap-strictness)") ])

let snap_both =
  Style
    ( "snap-both",
      [ (Scroll_snap_type, "both var(--tw-scroll-snap-strictness)") ] )

let snap_mandatory =
  Style
    ("snap-mandatory", [ (Custom "--tw-scroll-snap-strictness", "mandatory") ])

let snap_proximity =
  Style
    ("snap-proximity", [ (Custom "--tw-scroll-snap-strictness", "proximity") ])

let snap_start = Style ("snap-start", [ (Scroll_snap_align, "start") ])
let snap_end = Style ("snap-end", [ (Scroll_snap_align, "end") ])
let snap_center = Style ("snap-center", [ (Scroll_snap_align, "center") ])
let snap_align_none = Style ("snap-align-none", [ (Scroll_snap_align, "none") ])
let snap_normal = Style ("snap-normal", [ (Scroll_snap_stop, "normal") ])
let snap_always = Style ("snap-always", [ (Scroll_snap_stop, "always") ])
let scroll_auto = Style ("scroll-auto", [ (Scroll_behavior, "auto") ])
let scroll_smooth = Style ("scroll-smooth", [ (Scroll_behavior, "smooth") ])
let object_contain = Style ("object-contain", [ (Object_fit, "contain") ])
let object_cover = Style ("object-cover", [ (Object_fit, "cover") ])
let object_fill = Style ("object-fill", [ (Object_fit, "fill") ])
let object_none = Style ("object-none", [ (Object_fit, "none") ])

let object_scale_down =
  Style ("object-scale-down", [ (Object_fit, "scale-down") ])

let sr_only =
  Style
    ( "sr-only",
      [
        (Position, "absolute");
        (Width, "1px");
        (Height, "1px");
        (Padding, "0");
        (Margin, "-1px");
        (Overflow, "hidden");
        (Clip, "rect(0, 0, 0, 0)");
        (White_space, "nowrap");
        (Border_width, "0");
      ] )

let not_sr_only =
  Style
    ( "not-sr-only",
      [
        (Position, "static");
        (Width, "auto");
        (Height, "auto");
        (Padding, "0");
        (Margin, "0");
        (Overflow, "visible");
        (Clip, "auto");
        (White_space, "normal");
      ] )

let line_clamp_1 = Style ("line-clamp-1", [ (Webkit_line_clamp, "1") ])
let line_clamp_2 = Style ("line-clamp-2", [ (Webkit_line_clamp, "2") ])
let line_clamp_3 = Style ("line-clamp-3", [ (Webkit_line_clamp, "3") ])
let line_clamp_4 = Style ("line-clamp-4", [ (Webkit_line_clamp, "4") ])
let line_clamp_5 = Style ("line-clamp-5", [ (Webkit_line_clamp, "5") ])
let line_clamp_6 = Style ("line-clamp-6", [ (Webkit_line_clamp, "6") ])
let line_clamp_none = Style ("line-clamp-none", [ (Webkit_line_clamp, "none") ])

(* Responsive and state modifiers *)
let focus t = Modified (Focus, t)

let focus_visible =
  Style
    ( "focus-visible",
      [ (Outline, "2px solid transparent"); (Outline_offset, "2px") ] )

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
let sm_transform_none = sm (Style ("transform-none", [ (Transform, "none") ]))
let text_gray_300 = text ~shade:300 Gray
let dark_bg_gray_600 = dark (bg ~shade:600 Gray)
let hover_opacity_70 = hover (Style ("opacity-70", [ (Opacity, "0.7") ]))

let bg_gradient_to_b =
  Style
    ( "bg-gradient-to-b",
      [
        ( Background_image,
          "linear-gradient(to bottom, var(--tw-gradient-stops))" );
      ] )

let from_gray_50 = Style ("from-gray-50", [])
let to_white = Style ("to-white", [])

let bg_gradient_to_br =
  Style
    ( "bg-gradient-to-br",
      [
        ( Background_image,
          "linear-gradient(to bottom right, var(--tw-gradient-stops))" );
      ] )

let from_sky_50 = Style ("from-sky-50", [])
let via_blue_50 = Style ("via-blue-50", [])
let to_indigo_50 = Style ("to-indigo-50", [])

let antialiased =
  Style
    ( "antialiased",
      [
        (Webkit_font_smoothing, "antialiased");
        (Moz_osx_font_smoothing, "grayscale");
      ] )

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

let w_custom value = Style ("w-custom", [ (Width, value) ])

let transform =
  Style
    ( "transform",
      [
        (Custom "--tw-translate-x", "0");
        (Custom "--tw-translate-y", "0");
        (Css.Custom "--tw-rotate", "0");
        (Css.Custom "--tw-skew-x", "0");
        (Css.Custom "--tw-skew-y", "0");
        (Css.Custom "--tw-scale-x", "1");
        (Css.Custom "--tw-scale-y", "1");
        ( Css.Transform,
          "translateX(var(--tw-translate-x)) translateY(var(--tw-translate-y)) \
           rotate(var(--tw-rotate)) skewX(var(--tw-skew-x)) \
           skewY(var(--tw-skew-y)) scaleX(var(--tw-scale-x)) \
           scaleY(var(--tw-scale-y))" );
      ] )

let transform_none = Style ("transform-none", [ (Transform, "none") ])
let transform_gpu = Style ("transform-gpu", [ (Transform, "translateZ(0)") ])

(* Filter utilities *)
let blur_none = Style ("blur-none", [ (Filter, "blur(0)") ])
let blur_sm = Style ("blur-sm", [ (Filter, "blur(4px)") ])
let blur = Style ("blur", [ (Filter, "blur(8px)") ])
let blur_md = Style ("blur-md", [ (Filter, "blur(12px)") ])
let blur_lg = Style ("blur-lg", [ (Filter, "blur(16px)") ])
let blur_xl = Style ("blur-xl", [ (Filter, "blur(24px)") ])
let blur_2xl = Style ("blur-2xl", [ (Filter, "blur(40px)") ])
let blur_3xl = Style ("blur-3xl", [ (Filter, "blur(64px)") ])

let brightness n =
  let class_name = "brightness-" ^ string_of_int n in
  let value = string_of_float (float_of_int n /. 100.0) in
  Style (class_name, [ (Filter, "brightness(" ^ value ^ ")") ])

let brightness_0 = brightness 0
let brightness_50 = brightness 50
let brightness_75 = brightness 75
let brightness_90 = brightness 90
let brightness_95 = brightness 95
let brightness_100 = brightness 100
let brightness_105 = brightness 105
let brightness_110 = brightness 110
let brightness_125 = brightness 125
let brightness_150 = brightness 150
let brightness_200 = brightness 200

let contrast n =
  let class_name = "contrast-" ^ string_of_int n in
  let value = string_of_float (float_of_int n /. 100.0) in
  Style (class_name, [ (Filter, "contrast(" ^ value ^ ")") ])

let contrast_0 = contrast 0
let contrast_50 = contrast 50
let contrast_75 = contrast 75
let contrast_100 = contrast 100
let contrast_125 = contrast 125
let contrast_150 = contrast 150
let contrast_200 = contrast 200
let grayscale_0 = Style ("grayscale-0", [ (Filter, "grayscale(0)") ])
let grayscale = Style ("grayscale", [ (Filter, "grayscale(1)") ])

(* Backdrop filter utilities *)
let backdrop_blur_none =
  Style ("backdrop-blur-none", [ (Backdrop_filter, "blur(0)") ])

let backdrop_blur_sm =
  Style ("backdrop-blur-sm", [ (Backdrop_filter, "blur(4px)") ])

let backdrop_blur = Style ("backdrop-blur", [ (Backdrop_filter, "blur(8px)") ])

let backdrop_blur_md =
  Style ("backdrop-blur-md", [ (Backdrop_filter, "blur(12px)") ])

let backdrop_blur_lg =
  Style ("backdrop-blur-lg", [ (Backdrop_filter, "blur(16px)") ])

let backdrop_blur_xl =
  Style ("backdrop-blur-xl", [ (Backdrop_filter, "blur(24px)") ])

let backdrop_blur_2xl =
  Style ("backdrop-blur-2xl", [ (Backdrop_filter, "blur(40px)") ])

let backdrop_blur_3xl =
  Style ("backdrop-blur-3xl", [ (Backdrop_filter, "blur(64px)") ])

let backdrop_brightness n =
  let class_name = Core.Pp.str [ "backdrop-brightness-"; string_of_int n ] in
  Style
    ( class_name,
      [
        ( Backdrop_filter,
          Core.Pp.str
            [ "brightness("; string_of_float (float_of_int n /. 100.); ")" ] );
      ] )

let backdrop_brightness_0 = backdrop_brightness 0
let backdrop_brightness_50 = backdrop_brightness 50
let backdrop_brightness_75 = backdrop_brightness 75
let backdrop_brightness_90 = backdrop_brightness 90
let backdrop_brightness_95 = backdrop_brightness 95
let backdrop_brightness_100 = backdrop_brightness 100
let backdrop_brightness_105 = backdrop_brightness 105
let backdrop_brightness_110 = backdrop_brightness 110
let backdrop_brightness_125 = backdrop_brightness 125
let backdrop_brightness_150 = backdrop_brightness 150
let backdrop_brightness_200 = backdrop_brightness 200

let backdrop_contrast n =
  let class_name = Core.Pp.str [ "backdrop-contrast-"; string_of_int n ] in
  Style
    ( class_name,
      [
        ( Backdrop_filter,
          Core.Pp.str
            [ "contrast("; string_of_float (float_of_int n /. 100.); ")" ] );
      ] )

let backdrop_contrast_0 = backdrop_contrast 0
let backdrop_contrast_50 = backdrop_contrast 50
let backdrop_contrast_75 = backdrop_contrast 75
let backdrop_contrast_100 = backdrop_contrast 100
let backdrop_contrast_125 = backdrop_contrast 125
let backdrop_contrast_150 = backdrop_contrast 150
let backdrop_contrast_200 = backdrop_contrast 200

let backdrop_grayscale_0 =
  Style ("backdrop-grayscale-0", [ (Backdrop_filter, "grayscale(0)") ])

let backdrop_grayscale =
  Style ("backdrop-grayscale", [ (Backdrop_filter, "grayscale(1)") ])

let backdrop_opacity n =
  let class_name = Core.Pp.str [ "backdrop-opacity-"; string_of_int n ] in
  Style
    ( class_name,
      [
        ( Backdrop_filter,
          Core.Pp.str
            [ "opacity("; string_of_float (float_of_int n /. 100.); ")" ] );
      ] )

let backdrop_saturate n =
  let class_name = Core.Pp.str [ "backdrop-saturate-"; string_of_int n ] in
  Style
    ( class_name,
      [
        ( Backdrop_filter,
          Core.Pp.str
            [ "saturate("; string_of_float (float_of_int n /. 100.); ")" ] );
      ] )

let backdrop_saturate_0 = backdrop_saturate 0
let backdrop_saturate_50 = backdrop_saturate 50
let backdrop_saturate_100 = backdrop_saturate 100
let backdrop_saturate_150 = backdrop_saturate 150
let backdrop_saturate_200 = backdrop_saturate 200

(* Animation utilities *)
let animate_none = Style ("animate-none", [ (Animation, "none") ])

let animate_spin =
  Style ("animate-spin", [ (Animation, "spin 1s linear infinite") ])

let animate_ping =
  Style
    ( "animate-ping",
      [ (Animation, "ping 1s cubic-bezier(0, 0, 0.2, 1) infinite") ] )

let animate_pulse =
  Style
    ( "animate-pulse",
      [ (Animation, "pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite") ] )

let animate_bounce =
  Style ("animate-bounce", [ (Animation, "bounce 1s infinite") ])

(* Table utilities *)
let table_auto = Style ("table-auto", [ (Table_layout, "auto") ])
let table_fixed = Style ("table-fixed", [ (Table_layout, "fixed") ])

let border_collapse =
  Style ("border-collapse", [ (Border_collapse, "collapse") ])

let border_separate =
  Style ("border-separate", [ (Border_collapse, "separate") ])

let border_spacing n =
  let value = spacing_to_rem n in
  Style ("border-spacing-" ^ string_of_int n, [ (Border_spacing, value) ])

let border_spacing_0 = Style ("border-spacing-0", [ (Border_spacing, "0") ])
let border_spacing_1 = border_spacing 1
let border_spacing_2 = border_spacing 2
let border_spacing_4 = border_spacing 4
let border_spacing_8 = border_spacing 8

(* Form utilities - equivalent to @tailwindcss/forms plugin *)
let form_input =
  Style
    ( "form-input",
      [
        (Appearance, "none");
        (Background_color, "white");
        (Border_color, "rgb(209 213 219)");
        (Border_width, "1px");
        (Border_radius, "0.375rem");
        (Padding_top, "0.5rem");
        (Padding_right, "0.75rem");
        (Padding_bottom, "0.5rem");
        (Padding_left, "0.75rem");
        (Font_size, "1rem");
        (Line_height, "1.5rem");
        (Custom "outline", "2px solid transparent");
        (Custom "outline-offset", "2px");
      ] )

let form_textarea =
  Style
    ( "form-textarea",
      [
        (Appearance, "none");
        (Background_color, "white");
        (Border_color, "rgb(209 213 219)");
        (Border_width, "1px");
        (Border_radius, "0.375rem");
        (Padding_top, "0.5rem");
        (Padding_right, "0.75rem");
        (Padding_bottom, "0.5rem");
        (Padding_left, "0.75rem");
        (Font_size, "1rem");
        (Line_height, "1.5rem");
        (Resize, "vertical");
      ] )

let form_select =
  Style
    ( "form-select",
      [
        (Appearance, "none");
        (Background_color, "white");
        (Border_color, "rgb(209 213 219)");
        (Border_width, "1px");
        (Border_radius, "0.375rem");
        (Padding_top, "0.5rem");
        (Padding_right, "2.5rem");
        (Padding_bottom, "0.5rem");
        (Padding_left, "0.75rem");
        (Font_size, "1rem");
        (Line_height, "1.5rem");
        ( Background_image,
          "url(\"data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' \
           fill='none' viewBox='0 0 20 20'%3e%3cpath stroke='%236b7280' \
           stroke-linecap='round' stroke-linejoin='round' stroke-width='1.5' \
           d='M6 8l4 4 4-4'/%3e%3c/svg%3e\")" );
        (Background_position, "right 0.5rem center");
        (Background_repeat, "no-repeat");
        (Background_size, "1.5em 1.5em");
      ] )

let form_checkbox =
  Style
    ( "form-checkbox",
      [
        (Appearance, "none");
        (Width, "1rem");
        (Height, "1rem");
        (Background_color, "white");
        (Border_color, "rgb(209 213 219)");
        (Border_width, "1px");
        (Border_radius, "0.25rem");
        (Color, "rgb(59 130 246)");
        (Flex_shrink, "0");
        (Display, "inline-block");
        (Vertical_align, "middle");
      ] )

let form_radio =
  Style
    ( "form-radio",
      [
        (Appearance, "none");
        (Width, "1rem");
        (Height, "1rem");
        (Background_color, "white");
        (Border_color, "rgb(209 213 219)");
        (Border_width, "1px");
        (Border_radius, "100%");
        (Color, "rgb(59 130 246)");
        (Flex_shrink, "0");
        (Display, "inline-block");
        (Vertical_align, "middle");
      ] )

(* Focus states for form elements *)
let focus_ring =
  Style
    ( "focus:ring",
      [
        (Custom "outline", "2px solid transparent");
        (Custom "outline-offset", "2px");
        ( Custom "--tw-ring-offset-shadow",
          "var(--tw-ring-inset) 0 0 0 var(--tw-ring-offset-width) \
           var(--tw-ring-offset-color)" );
        ( Custom "--tw-ring-shadow",
          "var(--tw-ring-inset) 0 0 0 calc(3px + var(--tw-ring-offset-width)) \
           var(--tw-ring-color)" );
        ( Box_shadow,
          "var(--tw-ring-offset-shadow), var(--tw-ring-shadow), \
           var(--tw-shadow, 0 0 #0000)" );
      ] )

let focus_ring_2 =
  Style
    ( "focus:ring-2",
      [
        ( Custom "--tw-ring-offset-shadow",
          "var(--tw-ring-inset) 0 0 0 var(--tw-ring-offset-width) \
           var(--tw-ring-offset-color)" );
        ( Custom "--tw-ring-shadow",
          "var(--tw-ring-inset) 0 0 0 calc(2px + var(--tw-ring-offset-width)) \
           var(--tw-ring-color)" );
        ( Box_shadow,
          "var(--tw-ring-offset-shadow), var(--tw-ring-shadow), \
           var(--tw-shadow, 0 0 #0000)" );
      ] )

let focus_ring_blue_500 =
  Style
    ("focus:ring-blue-500", [ (Custom "--tw-ring-color", "rgb(59 130 246)") ])

let focus_border_blue_500 =
  Style ("focus:border-blue-500", [ (Border_color, "rgb(59 130 246)") ])

(* Peer and group utilities *)
let peer = Style ("peer", []) (* Marker class for peer relationships *)
let group = Style ("group", []) (* Marker class for group relationships *)

(* Peer modifiers *)
let peer_hover style = Modified (Peer_hover, style)
let peer_focus style = Modified (Peer_focus, style)
let peer_checked style = Modified (Peer_checked, style)

(* Additional group modifiers *)
let group_focus style = Modified (Group_focus, style)

(* ARIA state modifiers *)
let aria_checked style = Modified (Aria_checked, style)
let aria_expanded style = Modified (Aria_expanded, style)
let aria_selected style = Modified (Aria_selected, style)
let aria_disabled style = Modified (Aria_disabled, style)

let from_color color =
  let class_name = "from-" ^ color_name color in
  (* CSS variables for gradients, skip for now *)
  Style (class_name, [])

let to_color color =
  let class_name = "to-" ^ color_name color in
  (* CSS variables for gradients, skip for now *)
  Style (class_name, [])

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
      | Group_focus -> "group-focus:" ^ base_class
      | Peer_hover -> "peer-hover:" ^ base_class
      | Peer_focus -> "peer-focus:" ^ base_class
      | Peer_checked -> "peer-checked:" ^ base_class
      | Aria_checked -> "aria-checked:" ^ base_class
      | Aria_expanded -> "aria-expanded:" ^ base_class
      | Aria_selected -> "aria-selected:" ^ base_class
      | Aria_disabled -> "aria-disabled:" ^ base_class
      | Dark -> "dark:" ^ base_class
      | Responsive prefix -> prefix ^ ":" ^ base_class)

let to_classes styles = styles |> List.map to_class |> String.concat " "
let to_string t = to_class t
let classes_to_string = to_classes

(* Pretty printing *)
let pp t = to_string t

(* Prose utilities *)
let prose =
  Style ("prose", [ (Color, "var(--tw-prose-body)"); (Max_width, "65ch") ])

let prose_sm =
  Style ("prose-sm", [ (Font_size, "0.875rem"); (Line_height, "1.7142857") ])

let prose_lg =
  Style ("prose-lg", [ (Font_size, "1.125rem"); (Line_height, "1.7777778") ])

let prose_xl =
  Style ("prose-xl", [ (Font_size, "1.25rem"); (Line_height, "1.8") ])

let prose_gray = Style ("prose-gray", [ (Color, "rgb(75 85 99)") ])

(* Opacity utilities *)
