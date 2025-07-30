(** CSS generation utilities *)

(** {1 Types} *)

type property_name =
  | Background_color
  | Color
  | Border_color
  | Padding
  | Padding_left
  | Padding_right
  | Padding_bottom
  | Padding_top
  | Margin
  | Margin_left
  | Margin_right
  | Margin_top
  | Margin_bottom
  | Gap
  | Column_gap
  | Row_gap
  | Width
  | Height
  | Min_width
  | Min_height
  | Max_width
  | Max_height
  | Font_size
  | Line_height
  | Font_weight
  | Font_style
  | Text_align
  | Text_decoration
  | Letter_spacing
  | White_space
  | Display
  | Position
  | Flex_direction
  | Flex_wrap
  | Flex
  | Flex_grow
  | Flex_shrink
  | Align_items
  | Justify_content
  | Grid_template_columns
  | Grid_template_rows
  | Border_width
  | Border_radius
  | Box_shadow
  | Opacity
  | Transition
  | Transform
  | Cursor
  | Table_layout
  | Border_collapse
  | Border_spacing
  | User_select
  | Pointer_events
  | Overflow
  | Object_fit
  | Top
  | Right
  | Bottom
  | Left
  | Z_index
  | Border_top_width
  | Border_right_width
  | Border_bottom_width
  | Border_left_width
  | Outline
  | Outline_offset
  | Clip
  | Filter
  | Background_image
  | Animation
  | Appearance
  | Overflow_x
  | Overflow_y
  | Resize
  | Vertical_align
  | Box_sizing
  | Font_family
  | Background_position
  | Background_repeat
  | Background_size
  | Webkit_font_smoothing
  | Moz_osx_font_smoothing
  | Webkit_line_clamp
  | Backdrop_filter
  | Scroll_snap_type
  | Scroll_snap_align
  | Scroll_snap_stop
  | Scroll_behavior
  | Custom of string  (** CSS property names as a variant type *)

type property = property_name * string
(** A CSS property as (name, value) pair *)

type rule = { selector : string; properties : property list }
type media_query = { condition : string; rules : rule list }
type stylesheet = { rules : rule list; media_queries : media_query list }

(** {1 Creation} *)

val rule : selector:string -> property list -> rule
(** [rule ~selector properties] creates a CSS rule with a selector and
    properties. *)

val media : condition:string -> rule list -> media_query
(** [media ~condition rules] creates a media query. *)

val stylesheet : ?media_queries:media_query list -> rule list -> stylesheet
(** [stylesheet ?media_queries rules] creates a stylesheet. *)

(** {1 Rendering} *)

val rule_to_string : rule -> string
(** [rule_to_string rule] renders a single rule to CSS. *)

val media_query_to_string : media_query -> string
(** [media_query_to_string query] renders a media query to CSS. *)

val to_string : ?minify:bool -> stylesheet -> string
(** [to_string ?minify stylesheet] renders a complete stylesheet to CSS. *)

(** {1 Utilities} *)

val merge_rules : rule list -> rule list
(** [merge_rules rules] merges rules with identical selectors. *)

val merge_by_properties : rule list -> rule list
(** [merge_by_properties rules] merges rules with identical properties into 
    combined selectors (e.g., .a{color:red} and .b{color:red} becomes .a,.b{color:red}). *)

val deduplicate_properties : property list -> property list
(** [deduplicate_properties properties] removes duplicate properties, keeping
    the last occurrence. *)

val minify_selector : string -> string
(** [minify_selector selector] minifies a CSS selector. *)

val minify_value : string -> string
(** [minify_value value] minifies a CSS value. *)
