(** A type-safe, ergonomic DSL for Tailwind CSS using nominal types. *)

open Css

(** {1 Core Types} *)

(* Abstract color type *)
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

(* Common size variants used across multiple utilities *)
type size = [ `None | `Xs | `Sm | `Md | `Lg | `Xl | `Xl_2 | `Xl_3 | `Full ]

(* Polymorphic variant types for composable sizing *)
type spacing = [ `Px | `Full | `Val of float ]
type margin = [ spacing | `Auto ]
type scale = [ spacing | size | `Screen | `Min | `Max | `Fit ]
type max_scale = [ scale | `Xl_4 | `Xl_5 | `Xl_6 | `Xl_7 ]
type shadow = [ size | `Inner ]

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
  | Data_state of string (* data-state="value" *)
  | Data_variant of string (* data-variant="value" *)
  | Data_active (* data-active="true" or data-active *)
  | Data_inactive (* data-inactive="true" or data-inactive *)
  | Data_custom of string * string (* data-{key}="{value}" *)

type t =
  | Style of string * property list (* class name, properties *)
  | Modified of modifier * t
  | Group of t list (* group of styles *)

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

(* Color constructors *)
let black = Black
let white = White
let gray = Gray
let slate = Slate
let zinc = Zinc
let red = Red
let orange = Orange
let amber = Amber
let yellow = Yellow
let lime = Lime
let green = Green
let emerald = Emerald
let teal = Teal
let cyan = Cyan
let sky = Sky
let blue = Blue
let indigo = Indigo
let violet = Violet
let purple = Purple
let fuchsia = Fuchsia
let pink = Pink
let rose = Rose

(* Value constructors *)

(* Spacing constructors *)
let int n = `Val (float_of_int n *. 0.25)
let one_px = `Px
let full = `Full
let rem f = `Val f

(* Margin constructors *)
let auto = `Auto

(* Size constructors *)
let screen = `Screen
let min = `Min
let max = `Max
let fit = `Fit

(* Max width constructors *)
let none = `None
let xs = `Xs
let sm = `Sm
let md = `Md
let lg = `Lg
let xl = `Xl
let xl_2 = `Xl_2
let xl_3 = `Xl_3
let xl_4 = `Xl_4
let xl_5 = `Xl_5
let xl_6 = `Xl_6
let xl_7 = `Xl_7

(* Value constructors *)
let inner = `Inner

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

let pp_spacing_suffix : spacing -> string = function
  | `Px -> "px"
  | `Full -> "full"
  | `Val f ->
      (* Convert rem values back to Tailwind scale *)
      let n = int_of_float (f /. 0.25) in
      string_of_int n

let pp_size_suffix : size -> string = function
  | `None -> "none"
  | `Xs -> "xs"
  | `Sm -> "sm"
  | `Md -> "md"
  | `Lg -> "lg"
  | `Xl -> "xl"
  | `Xl_2 -> "2xl"
  | `Xl_3 -> "3xl"
  | `Full -> "full"

let pp_scale_suffix : scale -> string = function
  | `Screen -> "screen"
  | `Min -> "min"
  | `Max -> "max"
  | `Fit -> "fit"
  | #spacing as s -> pp_spacing_suffix s
  | #size as s -> pp_size_suffix s

let pp_margin_suffix : margin -> string = function
  | `Auto -> "auto"
  | #spacing as s -> pp_spacing_suffix s

let pp_max_scale_suffix : max_scale -> string = function
  | #size as s -> pp_size_suffix s
  | `Xl_4 -> "4xl"
  | `Xl_5 -> "5xl"
  | `Xl_6 -> "6xl"
  | `Xl_7 -> "7xl"
  | #scale as s -> pp_scale_suffix s

(** Format float for CSS - ensures leading zero and removes trailing dot *)
let css_float f =
  let s = string_of_float f in
  let s = if String.starts_with ~prefix:"." s then "0" ^ s else s in
  if String.ends_with ~suffix:"." s then String.sub s 0 (String.length s - 1)
  else s

let pp_spacing : spacing -> string = function
  | `Px -> "1px"
  | `Full -> "100%"
  | `Val f -> if f = 0.0 then "0" else Core.Pp.str [ css_float f; "rem" ]

let pp_margin : margin -> string = function
  | `Auto -> "auto"
  | #spacing as s -> pp_spacing s

let pp_size : size -> string = function
  | `None -> "0"
  | `Xs -> "0.125rem"
  | `Sm -> "0.25rem"
  | `Md -> "0.375rem"
  | `Lg -> "0.5rem"
  | `Xl -> "0.75rem"
  | `Xl_2 -> "1rem"
  | `Xl_3 -> "1.5rem"
  | `Full -> "100%"

let pp_scale : scale -> string = function
  | `Screen -> "100vh"
  | `Min -> "min-content"
  | `Max -> "max-content"
  | `Fit -> "fit-content"
  | #spacing as s -> pp_spacing s
  | #size as s -> pp_size s

let pp_max_scale : max_scale -> string = function
  | `None -> "none"
  | `Xs -> "20rem"
  | `Sm -> "24rem"
  | `Md -> "28rem"
  | `Lg -> "32rem"
  | `Xl -> "36rem"
  | `Xl_2 -> "42rem"
  | `Xl_3 -> "48rem"
  | `Xl_4 -> "56rem"
  | `Xl_5 -> "64rem"
  | `Xl_6 -> "72rem"
  | `Xl_7 -> "80rem"
  | #scale as s -> pp_scale s

(** {1 Spacing} *)

let p s =
  let class_name = "p-" ^ pp_spacing_suffix s in
  Style (class_name, [ (Padding, pp_spacing s) ])

let px s =
  let v = pp_spacing s in
  let class_name = "px-" ^ pp_spacing_suffix s in
  Style (class_name, [ (Padding_left, v); (Padding_right, v) ])

let py s =
  let v = pp_spacing s in
  let class_name = "py-" ^ pp_spacing_suffix s in
  Style (class_name, [ (Padding_bottom, v); (Padding_top, v) ])

let pt s =
  let class_name = "pt-" ^ pp_spacing_suffix s in
  Style (class_name, [ (Padding_top, pp_spacing s) ])

let pr s =
  let class_name = "pr-" ^ pp_spacing_suffix s in
  Style (class_name, [ (Padding_right, pp_spacing s) ])

let pb s =
  let class_name = "pb-" ^ pp_spacing_suffix s in
  Style (class_name, [ (Padding_bottom, pp_spacing s) ])

let pl s =
  let class_name = "pl-" ^ pp_spacing_suffix s in
  Style (class_name, [ (Padding_left, pp_spacing s) ])

let m m =
  let class_name = "m-" ^ pp_margin_suffix m in
  Style (class_name, [ (Margin, pp_margin m) ])

let mx m =
  let v = pp_margin m in
  let class_name = "mx-" ^ pp_margin_suffix m in
  Style (class_name, [ (Margin_left, v); (Margin_right, v) ])

let my m =
  let v = pp_margin m in
  let class_name = "my-" ^ pp_margin_suffix m in
  Style (class_name, [ (Margin_bottom, v); (Margin_top, v) ])

let mt m =
  let class_name = "mt-" ^ pp_margin_suffix m in
  Style (class_name, [ (Margin_top, pp_margin m) ])

let mr m =
  let class_name = "mr-" ^ pp_margin_suffix m in
  Style (class_name, [ (Margin_right, pp_margin m) ])

let mb m =
  let class_name = "mb-" ^ pp_margin_suffix m in
  Style (class_name, [ (Margin_bottom, pp_margin m) ])

let ml m =
  let class_name = "ml-" ^ pp_margin_suffix m in
  Style (class_name, [ (Margin_left, pp_margin m) ])

let gap s =
  let class_name = "gap-" ^ pp_spacing_suffix s in
  Style (class_name, [ (Gap, pp_spacing s) ])

let gap_x s =
  let class_name = "gap-x-" ^ pp_spacing_suffix s in
  Style (class_name, [ (Column_gap, pp_spacing s) ])

let gap_y s =
  let class_name = "gap-y-" ^ pp_spacing_suffix s in
  Style (class_name, [ (Row_gap, pp_spacing s) ])


(** {1 Sizing} *)

let w (s : scale) =
  let class_name = "w-" ^ pp_scale_suffix s in
  Style (class_name, [ (Width, pp_scale s) ])

let h (s : scale) =
  let class_name = "h-" ^ pp_scale_suffix s in
  match s with
  | `Screen -> Style (class_name, [ (Height, "100vh") ])
  | _ -> Style (class_name, [ (Height, pp_scale s) ])

let min_w (s : scale) =
  let class_name = "min-w-" ^ pp_scale_suffix s in
  Style (class_name, [ (Min_width, pp_scale s) ])

let min_h (s : scale) =
  let class_name = "min-h-" ^ pp_scale_suffix s in
  match s with
  | `Screen -> Style (class_name, [ (Min_height, "100vh") ])
  | _ -> Style (class_name, [ (Min_height, pp_scale s) ])

let max_w (mw : max_scale) =
  let class_name = "max-w-" ^ pp_max_scale_suffix mw in
  Style (class_name, [ (Max_width, pp_max_scale mw) ])

(** {1 Typography} *)

let text_xs =
  Style ("text-xs", [ (Font_size, "0.75rem"); (Line_height, "1rem") ])

let text_sm =
  Style ("text-sm", [ (Font_size, "0.875rem"); (Line_height, "1.25rem") ])

let text_xl =
  Style ("text-xl", [ (Font_size, "1.25rem"); (Line_height, "1.75rem") ])

let text_2xl =
  Style ("text-2xl", [ (Font_size, "1.5rem"); (Line_height, "2rem") ])

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

(** {1 CSS Generation} *)

let rec to_css_properties = function
  | Style (_class_name, props) -> props
  | Modified (_modifier, t) -> to_css_properties t
  | Group styles -> List.concat_map to_css_properties styles

let to_css_rule ~selector styles =
  let properties = styles |> List.concat_map to_css_properties in
  rule ~selector properties

let css_of_classes selector_styles =
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
            | Data_state value ->
                (selector ^ "[data-state=\"" ^ value ^ "\"]", props)
            | Data_variant value ->
                (selector ^ "[data-variant=\"" ^ value ^ "\"]", props)
            | Data_active -> (selector ^ "[data-active]", props)
            | Data_inactive -> (selector ^ "[data-inactive]", props)
            | Data_custom (key, value) ->
                (selector ^ "[data-" ^ key ^ "=\"" ^ value ^ "\"]", props)
            | Dark ->
                ("@media (prefers-color-scheme: dark) { " ^ selector, props)
            | Responsive prefix ->
                ( "@media (min-width: "
                  ^ responsive_breakpoint prefix
                  ^ ") { " ^ selector,
                  props ))
          base
    | Group styles -> List.concat_map extract styles
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
let to_css ?(reset = true) tw_classes =
  let all_rules =
    tw_classes |> List.concat_map extract_selector_props |> group_by_selector
  in
  let rules =
    List.map
      (fun (selector, props) -> rule ~selector (deduplicate_properties props))
      all_rules
  in
  let final_rules = if reset then reset_rules @ rules else rules in
  stylesheet final_rules

let neg_mt s =
  let class_name = "-mt-" ^ pp_spacing_suffix s in
  Style (class_name, [ (Margin_top, "-" ^ pp_spacing s) ])

let neg_mr s =
  let class_name = "-mr-" ^ pp_spacing_suffix s in
  Style (class_name, [ (Margin_right, "-" ^ pp_spacing s) ])

let neg_mb s =
  let class_name = "-mb-" ^ pp_spacing_suffix s in
  Style (class_name, [ (Margin_bottom, "-" ^ pp_spacing s) ])

let neg_ml s =
  let class_name = "-ml-" ^ pp_spacing_suffix s in
  Style (class_name, [ (Margin_left, "-" ^ pp_spacing s) ])

let max_h s =
  let class_name = "max-h-" ^ pp_scale_suffix s in
  match s with
  | `Screen -> Style (class_name, [ (Max_height, "100vh") ])
  | _ -> Style (class_name, [ (Max_height, pp_scale s) ])

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
let font_medium = Style ("font-medium", [ (Font_weight, "500") ])
let font_semibold = Style ("font-semibold", [ (Font_weight, "600") ])
let font_bold = Style ("font-bold", [ (Font_weight, "700") ])
let font_extrabold = Style ("font-extrabold", [ (Font_weight, "800") ])
let font_black = Style ("font-black", [ (Font_weight, "900") ])

(* Font family utilities *)
let font_sans =
  Style
    ( "font-sans",
      [
        ( Font_family,
          "ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, 'Segoe \
           UI', Roboto, 'Helvetica Neue', Arial, 'Noto Sans', sans-serif, \
           'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto \
           Color Emoji'" );
      ] )

let font_serif =
  Style
    ( "font-serif",
      [
        ( Font_family,
          "ui-serif, Georgia, Cambria, 'Times New Roman', Times, serif" );
      ] )

let font_mono =
  Style
    ( "font-mono",
      [
        ( Font_family,
          "ui-monospace, SFMono-Regular, 'SF Mono', Consolas, 'Liberation \
           Mono', Menlo, monospace" );
      ] )

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

type width = [ size | `Default ]

let border (w : width) =
  let width_px, class_suffix = 
    match w with
    | `None -> "0", "-0"
    | `Xs | `Default -> "1px", ""  (* Default border is 1px *)
    | `Sm -> "2px", "-2" 
    | `Md -> "4px", "-4"  (* For borders, Md maps to 4px *)
    | `Lg -> "4px", "-4"
    | `Xl -> "8px", "-8"
    | `Xl_2 -> "8px", "-8"
    | `Xl_3 -> "8px", "-8"
    | `Full -> "8px", "-8"
  in
  let class_name = "border" ^ class_suffix in
  Style (class_name, [ (Border_width, width_px) ])

let border_t = Style ("border-t", [ (Border_top_width, "1px") ])
let border_r = Style ("border-r", [ (Border_right_width, "1px") ])
let border_b = Style ("border-b", [ (Border_bottom_width, "1px") ])
let border_l = Style ("border-l", [ (Border_left_width, "1px") ])

let rounded_value : size -> string = function
  | `None -> "0"
  | `Sm -> "0.125rem"
  | `Md -> "0.375rem"
  | `Lg -> "0.5rem"
  | `Xl -> "0.75rem"
  | `Xl_2 -> "1rem"
  | `Xl_3 -> "1.5rem"
  | `Full -> "9999px"
  | `Xs -> "0.0625rem"

let pp_rounded_suffix : size -> string = function
  | `None -> "none"
  | `Sm -> "sm"
  | `Md -> "md"
  | `Lg -> "lg"
  | `Xl -> "xl"
  | `Xl_2 -> "2xl"
  | `Xl_3 -> "3xl"
  | `Full -> "full"
  | `Xs -> "xs"

let rounded r =
  let class_name = "rounded-" ^ pp_rounded_suffix r in
  Style (class_name, [ (Border_radius, rounded_value r) ])

let shadow_value : shadow -> string = function
  | `None -> "0 0 #0000"
  | `Sm -> "0 1px 2px 0 #0000000d" (* rgba(0,0,0,0.05) = #0000000d *)
  | `Md ->
      "0 4px 6px -1px #0000001a,0 2px 4px -2px #0000000f" (* 0.1 and 0.06 *)
  | `Lg ->
      "0 10px 15px -3px #0000001a,0 4px 6px -4px #0000000d" (* 0.1 and 0.05 *)
  | `Xl ->
      "0 20px 25px -5px #0000001a,0 8px 10px -6px #0000000a" (* 0.1 and 0.04 *)
  | `Xl_2 -> "0 25px 50px -12px #00000040" (* 0.25 *)
  | `Inner -> "inset 0 2px 4px 0 #0000000f" (* 0.06 *)
  | `Xs -> "0 1px 1px 0 #0000000a" (* extra small *)
  | `Xl_3 -> "0 35px 60px -15px #00000059" (* extra extra large *)
  | `Full -> "0 0 0 0 #0000" (* no shadow, same as none *)

let pp_shadow_suffix : shadow -> string = function
  | `None -> "none"
  | `Sm -> "sm"
  | `Md -> "md"
  | `Lg -> "lg"
  | `Xl -> "xl"
  | `Xl_2 -> "2xl"
  | `Inner -> "inner"
  | `Xs -> "xs"
  | `Xl_3 -> "3xl"
  | `Full -> "full"

let shadow_colored_value : shadow -> string = function
  | `None -> "0 0 #0000"
  | `Sm -> "0 1px 2px 0 var(--tw-shadow-color)"
  | `Md ->
      "0 4px 6px -1px var(--tw-shadow-color),0 2px 4px -2px \
       var(--tw-shadow-color)"
  | `Lg ->
      "0 10px 15px -3px var(--tw-shadow-color),0 4px 6px -4px \
       var(--tw-shadow-color)"
  | `Xl ->
      "0 20px 25px -5px var(--tw-shadow-color),0 8px 10px -6px \
       var(--tw-shadow-color)"
  | `Xl_2 -> "0 25px 50px -12px var(--tw-shadow-color)"
  | `Inner -> "inset 0 2px 4px 0 var(--tw-shadow-color)"
  | `Xs -> "0 1px 1px 0 var(--tw-shadow-color)"
  | `Xl_3 -> "0 35px 60px -15px var(--tw-shadow-color)"
  | `Full -> "0 0 #0000"

let shadow s =
  let class_name = "shadow-" ^ pp_shadow_suffix s in
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

let opacity n =
  let class_name = "opacity-" ^ string_of_int n in
  let value =
    if n = 0 then "0"
    else if n = 100 then "1"
    else string_of_float (float_of_int n /. 100.0)
  in
  Style (class_name, [ (Opacity, value) ])

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

let ring (w : width) =
  let width, class_suffix = 
    match w with
    | `None -> "0", "0"
    | `Xs -> "1px", "1"
    | `Sm -> "2px", "2" 
    | `Default | `Md -> "3px", ""
    | `Lg -> "4px", "4"
    | `Xl -> "8px", "8"
    | `Xl_2 -> "8px", "8"  (* Map Xl_2 to 8px as well *)
    | `Xl_3 -> "8px", "8"  (* Map Xl_3 to 8px as well *)
    | `Full -> "8px", "8"  (* Map Full to 8px as well *)
  in
  let class_name = if class_suffix = "" then "ring" else "ring-" ^ class_suffix in
  let shadow_value = 
    if width = "0" then "0 0 #0000"
    else "0 0 0 " ^ width ^ " var(--tw-ring-color)"
  in
  Style 
    ( class_name,
      [
        (Custom "--tw-ring-color", "rgb(59 130 246 / 0.5)");
        (Box_shadow, 
         "var(--tw-ring-offset-shadow,0 0 #0000),var(--tw-ring-shadow,0 0 #0000),var(--tw-shadow,0 0 #0000)");
        (Custom "--tw-ring-shadow", shadow_value);
      ] )
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

(* Responsive and state modifiers *)

let focus_visible =
  Style
    ( "focus-visible",
      [ (Outline, "2px solid transparent"); (Outline_offset, "2px") ] )

let active t = Modified (Active, t)
let disabled t = Modified (Disabled, t)
let dark t = Modified (Dark, t)

(* New on_ style modifiers that take lists *)
let on_hover styles = Group (List.map (fun t -> Modified (Hover, t)) styles)
let on_focus styles = Group (List.map (fun t -> Modified (Focus, t)) styles)
let on_active styles = Group (List.map (fun t -> Modified (Active, t)) styles)

let on_disabled styles =
  Group (List.map (fun t -> Modified (Disabled, t)) styles)

let on_group_hover styles =
  Group (List.map (fun t -> Modified (Group_hover, t)) styles)

let on_group_focus styles =
  Group (List.map (fun t -> Modified (Group_focus, t)) styles)

let on_dark styles = Group (List.map (fun t -> Modified (Dark, t)) styles)

(* Additional on_* functions for consistency *)
let on_peer_hover styles =
  Group (List.map (fun t -> Modified (Peer_hover, t)) styles)

let on_peer_focus styles =
  Group (List.map (fun t -> Modified (Peer_focus, t)) styles)

let on_aria_disabled styles =
  Group (List.map (fun t -> Modified (Aria_disabled, t)) styles)

let on_data_active styles =
  Group (List.map (fun t -> Modified (Data_active, t)) styles)

let on_data_inactive styles =
  Group (List.map (fun t -> Modified (Data_inactive, t)) styles)

(* Check if a style already has a responsive modifier *)
let rec has_responsive_modifier = function
  | Style _ -> false
  | Modified (Responsive _, _) -> true
  | Modified (_, t) -> has_responsive_modifier t
  | Group styles -> List.exists has_responsive_modifier styles

let validate_no_nested_responsive styles =
  List.iter
    (fun style ->
      if has_responsive_modifier style then
        failwith
          "Cannot apply responsive modifiers to styles that already have \
           responsive modifiers")
    styles

let on_sm styles =
  validate_no_nested_responsive styles;
  Group (List.map (fun t -> Modified (Responsive "sm", t)) styles)

let on_md styles =
  validate_no_nested_responsive styles;
  Group (List.map (fun t -> Modified (Responsive "md", t)) styles)

let on_lg styles =
  validate_no_nested_responsive styles;
  Group (List.map (fun t -> Modified (Responsive "lg", t)) styles)

let on_xl styles =
  validate_no_nested_responsive styles;
  Group (List.map (fun t -> Modified (Responsive "xl", t)) styles)

let on_2xl styles =
  validate_no_nested_responsive styles;
  Group (List.map (fun t -> Modified (Responsive "2xl", t)) styles)

let bg_gradient_to_b =
  Style
    ( "bg-gradient-to-b",
      [
        ( Background_image,
          "linear-gradient(to bottom, var(--tw-gradient-stops))" );
      ] )

let bg_gradient_to_br =
  Style
    ( "bg-gradient-to-br",
      [
        ( Background_image,
          "linear-gradient(to bottom right, var(--tw-gradient-stops))" );
      ] )

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

let brightness n =
  let class_name = "brightness-" ^ string_of_int n in
  let value = string_of_float (float_of_int n /. 100.0) in
  Style (class_name, [ (Filter, "brightness(" ^ value ^ ")") ])

let contrast n =
  let class_name = "contrast-" ^ string_of_int n in
  let value = string_of_float (float_of_int n /. 100.0) in
  Style (class_name, [ (Filter, "contrast(" ^ value ^ ")") ])

let backdrop_brightness n =
  let class_name = Core.Pp.str [ "backdrop-brightness-"; string_of_int n ] in
  Style
    ( class_name,
      [
        ( Backdrop_filter,
          Core.Pp.str
            [ "brightness("; string_of_float (float_of_int n /. 100.); ")" ] );
      ] )

let backdrop_contrast n =
  let class_name = Core.Pp.str [ "backdrop-contrast-"; string_of_int n ] in
  Style
    ( class_name,
      [
        ( Backdrop_filter,
          Core.Pp.str
            [ "contrast("; string_of_float (float_of_int n /. 100.); ")" ] );
      ] )

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

(* Peer and group utilities *)
let peer = Style ("peer", []) (* Marker class for peer relationships *)
let group = Style ("group", []) (* Marker class for group relationships *)

(* Peer modifiers *)
let peer_checked style = Modified (Peer_checked, style)

(* ARIA state modifiers *)
let aria_checked style = Modified (Aria_checked, style)
let aria_expanded style = Modified (Aria_expanded, style)
let aria_selected style = Modified (Aria_selected, style)

(* Data attribute modifiers *)
let data_state value style = Modified (Data_state value, style)
let data_variant value style = Modified (Data_variant value, style)
let data_custom key value style = Modified (Data_custom (key, value), style)

let from_color ?(shade = 500) color =
  let class_name =
    match color with
    | Black | White -> "from-" ^ color_name color
    | _ -> Core.Pp.str [ "from-"; color_name color; "-"; string_of_int shade ]
  in
  (* CSS variables for gradients, skip for now *)
  Style (class_name, [])

let to_color ?(shade = 500) color =
  let class_name =
    match color with
    | Black | White -> "to-" ^ color_name color
    | _ -> Core.Pp.str [ "to-"; color_name color; "-"; string_of_int shade ]
  in
  (* CSS variables for gradients, skip for now *)
  Style (class_name, [])

let color_to_string = color_name

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
      | Data_state value -> "data-[state=" ^ value ^ "]:" ^ base_class
      | Data_variant value -> "data-[variant=" ^ value ^ "]:" ^ base_class
      | Data_active -> "data-[active]:" ^ base_class
      | Data_inactive -> "data-[inactive]:" ^ base_class
      | Data_custom (key, value) ->
          "data-[" ^ key ^ "=" ^ value ^ "]:" ^ base_class
      | Dark -> "dark:" ^ base_class
      | Responsive prefix -> prefix ^ ":" ^ base_class)
  | Group styles -> styles |> List.map to_class |> String.concat " "

let to_classes styles = styles |> List.map to_class |> String.concat " "
let to_string t = to_class t
let classes_to_string = to_classes

(* Pretty printing *)
let pp t = to_string t

(* Generate inline style string from properties *)
let properties_to_inline_style props =
  props
  |> List.map (fun (prop, value) ->
         let prop_str = Css.property_name_to_string prop in
         prop_str ^ ":" ^ value)
  |> String.concat ";"

(* Convert Tw styles to inline style attribute value *)
let to_inline_style styles =
  let all_props = List.concat_map to_css_properties styles in
  let deduped = deduplicate_properties all_props in
  properties_to_inline_style deduped

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

(* Line clamp utility function *)
let line_clamp n =
  let class_name = "line-clamp-" ^ string_of_int n in
  if n = 0 then Style ("line-clamp-none", [ (Webkit_line_clamp, "none") ])
  else Style (class_name, [ (Webkit_line_clamp, string_of_int n) ])

(* Opacity utilities *)
