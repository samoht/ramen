(** Type-safe Tailwind CSS

    This module provides a typed interface to the
    {{:https://tailwindcss.com/}Tailwind CSS} utility-first framework. It
    replaces raw string class names with a system of OCaml types and functions,
    preventing typos and invalid class combinations at compile-time.

    {1:model Model}

    The core of the library is the abstract type {!t}, which represents a
    single, atomic Tailwind class.

    A complete set of styles for an HTML element is constructed by creating a
    [t list]. This list is then converted to a space-separated string for use in
    a [class] attribute using the {!to_classes} function.

    State modifiers (e.g., for hover, focus, or responsive breakpoints) are
    implemented as higher-order functions that transform a style. For example,
    [hover bg_blue_700] creates a style that only applies on mouse hover.

    {1:usage Usage Example}

    {[
      let button =
        let styles =
          [
            bg_blue_500;
            text_white;
            font_bold;
            py_2;
            px_4;
            rounded_md;
            hover bg_blue_700 (* Apply blue-700 background on hover *);
            sm px_6 (* Use larger padding on small screens and up *);
          ]
        in
        Html.button [ class' (to_classes styles) ] [ Html.txt "Click Me" ]
    ]}

    The library aims to provide comprehensive coverage of the Tailwind API. *)

(** {1 Core Types}
    @see <https://tailwindcss.com/docs/customizing-colors> Customizing Colors *)

type t
(** The abstract type representing a single Tailwind CSS class. *)

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

(** A general-purpose scale for values like padding, margin, etc. *)
type spacing = Px | Full | Val of float | Int of int

(** A scale for margin, which uniquely allows Auto. *)
type margin = Auto | Px | Full | Val of float | Int of int

(** A scale for width and height, allowing Screen. *)
type size = Screen | Px | Full | Val of float | Int of int

type shadow = None | Sm | Md | Lg | Xl | Xl_2 | Inner
type rounded = None | Sm | Md | Lg | Xl | Xl_2 | Xl_3 | Full

(** {1 Color & Background} *)

val bg : ?shade:int -> color -> t
(** [bg ?shade color] creates a background color with optional shade. *)

val bg_transparent : t
(** Transparent background. *)

val bg_current : t
(** Current color background. *)

val text : ?shade:int -> color -> t
(** [text ?shade color] creates a text color with optional shade. *)

val text_transparent : t
(** Transparent text color. *)

val text_current : t
(** Current color text. *)

val border_color : ?shade:int -> color -> t
(** [border_color ?shade color] creates a border color with optional shade. *)

val border_transparent : t
(** Transparent border. *)

val border_current : t
(** Current color border. *)

val bg_white : t
(** White background. *)

val bg_black : t
(** Black background. *)

val text_white : t
(** White text color. *)

val text_black : t
(** Black text color. *)

val text_gray_300 : t
(** Light gray text (gray-300). *)

val text_gray_400 : t
(** Light gray text (gray-400). *)

val text_gray_500 : t
(** Medium-light gray text (gray-500). *)

val text_gray_600 : t
(** Medium gray text (gray-600). *)

val text_gray_700 : t
(** Medium-dark gray text (gray-700). *)

val text_gray_900 : t
(** Very dark gray text (gray-900). *)

val text_sky_100 : t
(** Very light sky blue text (sky-100). *)

val text_sky_700 : t
(** Medium-dark sky blue text (sky-700). *)

val text_sky_900 : t
(** Very dark sky blue text (sky-900). *)

val text_teal_600 : t
(** Medium teal text color (teal-600). *)

val bg_gray_50 : t
(** Very light gray background (gray-50). *)

val bg_gray_100 : t
(** Light gray background (gray-100). *)

val bg_sky_600 : t
(** Medium sky blue background (sky-600). *)

val bg_sky_700 : t
(** Medium-dark sky blue background (sky-700). *)

val bg_sky_900 : t
(** Very dark sky blue background (sky-900). *)

val border_gray_200 : t
(** Light gray border (gray-200). *)

val border_teal_600 : t
(** Medium teal border (teal-600). *)

val hover_text_gray_900 : t
(** Dark gray text on hover (gray-900). *)

val hover_text_sky_600 : t
(** Medium sky blue text on hover (sky-600). *)

val hover_text_white : t
(** White text on hover. *)

val hover_border_gray_300 : t
(** Light gray border on hover (gray-300). *)

val hover_bg_sky_800 : t
(** Dark sky blue background on hover (sky-800). *)

val dark_bg_gray_600 : t
(** Medium gray background in dark mode (gray-600). *)

val bg_gradient_to_b : t
(** Gradient direction to bottom. *)

val bg_gradient_to_br : t
(** Gradient direction to bottom right. *)

val from_sky_50 : t
(** Gradient from sky-50. *)

val via_blue_50 : t
(** Gradient via blue-50. *)

val to_indigo_50 : t
(** Gradient to indigo-50. *)

val from_gray_50 : t
(** Gradient from very light gray (gray-50). *)

val to_white : t
(** Gradient to white. *)

val from_color : color -> t
(** [from_color c] sets gradient from color. *)

val to_color : color -> t
(** [to_color c] sets gradient to color. *)

(** {1 Spacing}
    @see <https://tailwindcss.com/docs/padding> Padding
    @see <https://tailwindcss.com/docs/margin> Margin
    @see <https://tailwindcss.com/docs/space> Space Between
    @see <https://tailwindcss.com/docs/gap> Gap *)

val p : spacing -> t
(** [p spacing] sets padding on all sides. *)

val px : spacing -> t
(** [px spacing] sets horizontal padding (left and right). *)

val py : spacing -> t
(** [py spacing] sets vertical padding (top and bottom). *)

val pt : spacing -> t
(** [pt spacing] sets top padding. *)

val pr : spacing -> t
(** [pr spacing] sets right padding. *)

val pb : spacing -> t
(** [pb spacing] sets bottom padding. *)

val pl : spacing -> t
(** [pl spacing] sets left padding. *)

val p_1 : t
(** All-sides padding of 0.25rem (4px). *)

val px_3 : t
(** Horizontal padding of 0.75rem (12px). *)

val px_4 : t
(** Horizontal padding of 1rem (16px). *)

val px_6 : t
(** Horizontal padding of 1.5rem (24px). *)

val px_8 : t
(** Horizontal padding of 2rem (32px). *)

val py_2 : t
(** Vertical padding of 0.5rem (8px). *)

val py_8 : t
(** Vertical padding of 2rem (32px). *)

val py_20 : t
(** Vertical padding of 5rem (80px). *)

val py_24 : t
(** Vertical padding of 6rem (96px). *)

val pt_56 : t
(** Top padding of 14rem (224px). *)

val pb_2 : t
(** Bottom padding of 0.5rem (8px). *)

val pb_4 : t
(** Bottom padding of 1rem (16px). *)

val pb_8 : t
(** Bottom padding of 2rem (32px). *)

val pb_12 : t
(** Bottom padding of 3rem (48px). *)

val m : margin -> t
(** [m margin] sets margin on all sides. *)

val mx : margin -> t
(** [mx margin] sets horizontal margin (left and right). *)

val my : margin -> t
(** [my margin] sets vertical margin (top and bottom). *)

val mt : margin -> t
(** [mt margin] sets top margin. *)

val mr : margin -> t
(** [mr margin] sets right margin. *)

val mb : margin -> t
(** [mb margin] sets bottom margin. *)

val ml : margin -> t
(** [ml margin] sets left margin. *)

val m_1 : t
(** All-sides margin of 0.25rem (4px). *)

val mt_2 : t
(** Top margin of 0.5rem (8px). *)

val mb_4 : t
(** Bottom margin of 1rem (16px). *)

val mb_12 : t
(** Bottom margin of 3rem (48px). *)

val ml_4 : t
(** Left margin of 1rem (16px). *)

val ml_10 : t
(** Left margin of 2.5rem (40px). *)

val mx_auto : t
(** Automatic horizontal margins (centers element). *)

val md_ml_6 : t
(** Left margin of 1.5rem (24px) on medium screens and up. *)

val neg_mt : spacing -> t
(** [neg_mt spacing] sets negative top margin. *)

val neg_mr : spacing -> t
(** [neg_mr spacing] sets negative right margin. *)

val neg_mb : spacing -> t
(** [neg_mb spacing] sets negative bottom margin. *)

val neg_ml : spacing -> t
(** [neg_ml spacing] sets negative left margin. *)

val neg_mt_56 : t
(** Negative top margin of 14rem (224px). *)

val gap : spacing -> t
(** [gap spacing] sets gap for flexbox/grid layouts. *)

val gap_x : spacing -> t
(** [gap_x spacing] sets horizontal gap between flex/grid items. *)

val gap_y : spacing -> t
(** [gap_y spacing] sets vertical gap between flex/grid items. *)

val gap_2 : t
(** Gap of 0.5rem (8px) between items. *)

val gap_4 : t
(** Gap of 1rem (16px) between items. *)

val space_x : spacing -> t
(** [space_x spacing] sets horizontal space between children. *)

val space_y : spacing -> t
(** [space_y spacing] sets vertical space between children. *)

val space_x_4 : t
(** Horizontal space of 1rem between children. *)

(** {1 Sizing}
    @see <https://tailwindcss.com/docs/width> Width and Height *)

val w : size -> t
(** [w size] sets width using the size scale. *)

val w_auto : t
(** Automatic width. *)

val w_min : t
(** Minimum content width. *)

val w_max : t
(** Maximum content width. *)

val w_fit : t
(** Fit-content width. *)

val w_6 : t
(** Width of 1.5rem (24px). *)

val w_8 : t
(** Width of 2rem (32px). *)

val w_10 : t
(** Width of 2.5rem (40px). *)

val w_12 : t
(** Width of 3rem (48px). *)

val w_16 : t
(** Width of 4rem (64px). *)

val w_full : t
(** Full width (100%). *)

val w_custom : string -> t
(** [w_custom value] sets custom width value. *)

val h : size -> t
(** [h size] sets height using the size scale. *)

val h_auto : t
(** Automatic height. *)

val h_min : t
(** Minimum content height. *)

val h_max : t
(** Maximum content height. *)

val h_fit : t
(** Fit-content height. *)

val h_6 : t
(** Height of 1.5rem (24px). *)

val h_8 : t
(** Height of 2rem (32px). *)

val h_10 : t
(** Height of 2.5rem (40px). *)

val h_12 : t
(** Height of 3rem (48px). *)

val h_16 : t
(** Height of 4rem (64px). *)

val h_full : t
(** Full height (100%). *)

val min_w : spacing -> t
(** [min_w spacing] sets minimum width using the spacing scale. *)

val min_w_min : t
(** Minimum width of min-content. *)

val min_w_max : t
(** Minimum width of max-content. *)

val min_w_fit : t
(** Minimum width of fit-content. *)

val min_w_full : t
(** Minimum width of 100%. *)

val min_h : size -> t
(** [min_h size] sets minimum height using the size scale. *)

val min_h_min : t
(** Minimum height of min-content. *)

val min_h_max : t
(** Minimum height of max-content. *)

val min_h_fit : t
(** Minimum height of fit-content. *)

val min_h_screen : t
(** Minimum height of 100vh. *)

val max_w : spacing -> t
(** [max_w spacing] sets maximum width using the spacing scale. *)

val max_w_none : t
(** No maximum width. *)

val max_w_full : t
(** Maximum width of 100%. *)

val max_w_xs : t
(** Maximum width of 20rem (320px). *)

val max_w_sm : t
(** Maximum width of 24rem (384px). *)

val max_w_md : t
(** Maximum width of 28rem (448px). *)

val max_w_lg : t
(** Maximum width of 32rem (512px). *)

val max_w_xl : t
(** Maximum width of 36rem (576px). *)

val max_w_2xl : t
(** Maximum width of 42rem (672px). *)

val max_w_3xl : t
(** Maximum width of 48rem (768px). *)

val max_w_4xl : t
(** Maximum width of 56rem (896px). *)

val max_w_5xl : t
(** Maximum width of 64rem (1024px). *)

val max_w_6xl : t
(** Maximum width of 72rem (1152px). *)

val max_w_7xl : t
(** Maximum width of 80rem (1280px). *)

val max_h : size -> t
(** [max_h size] sets maximum height using the size scale. *)

val max_h_none : t
(** No maximum height. *)

(** {1 Layout}
    @see <https://tailwindcss.com/docs/display> Display
    @see <https://tailwindcss.com/docs/flex> Flexbox
    @see <https://tailwindcss.com/docs/position> Position *)

val block : t
(** Display block. *)

val inline : t
(** Display inline. *)

val inline_block : t
(** Display inline-block. *)

val flex : t
(** Display flex. *)

val inline_flex : t
(** Display inline-flex. *)

val grid : t
(** Display grid. *)

val inline_grid : t
(** Display inline-grid. *)

val hidden : t
(** Hide element (display: none). *)

val flex_col : t
(** Flex direction column. *)

val flex_row : t
(** Flex direction row. *)

val flex_row_reverse : t
(** Flex direction row-reverse. *)

val flex_col_reverse : t
(** Flex direction column-reverse. *)

val flex_wrap : t
(** Flex wrap. *)

val flex_wrap_reverse : t
(** Flex wrap reverse. *)

val flex_nowrap : t
(** Prevent flex items from wrapping. *)

val flex_1 : t
(** Flex: 1 1 0% (grow and shrink). *)

val flex_auto : t
(** Flex: 1 1 auto (grow and shrink from auto basis). *)

val flex_initial : t
(** Flex: 0 1 auto (shrink but not grow). *)

val flex_none : t
(** Flex: none (no grow or shrink). *)

val flex_grow : t
(** Allow flex item to grow. *)

val flex_grow_0 : t
(** Prevent flex item from growing. *)

val flex_shrink : t
(** Allow flex item to shrink. *)

val flex_shrink_0 : t
(** Prevent flex item from shrinking. *)

val items_start : t
(** Align items to start. *)

val items_end : t
(** Align items to end. *)

val items_center : t
(** Align items center. *)

val items_baseline : t
(** Align items to baseline. *)

val items_stretch : t
(** Stretch items to fill container. *)

val justify_start : t
(** Justify content to start. *)

val justify_end : t
(** Justify content to end. *)

val justify_center : t
(** Justify content center. *)

val justify_between : t
(** Justify content space-between. *)

val justify_around : t
(** Justify content with space around. *)

val justify_evenly : t
(** Justify content with equal space. *)

val grid_cols : int -> t
(** [grid_cols n] sets number of grid columns. *)

val grid_rows : int -> t
(** [grid_rows n] sets number of grid rows. *)

val grid_cols_1 : t
(** 1 grid column. *)

val grid_cols_2 : t
(** 2 grid columns. *)

val grid_cols_3 : t
(** 3 grid columns. *)

val grid_cols_4 : t
(** 4 grid columns. *)

val grid_cols_5 : t
(** 5 grid columns. *)

val grid_cols_6 : t
(** 6 grid columns. *)

val grid_cols_7 : t
(** 7 grid columns. *)

val grid_cols_8 : t
(** 8 grid columns. *)

val grid_cols_9 : t
(** 9 grid columns. *)

val grid_cols_10 : t
(** 10 grid columns. *)

val grid_cols_11 : t
(** 11 grid columns. *)

val grid_cols_12 : t
(** 12 grid columns. *)

val grid_rows_1 : t
(** 1 grid row. *)

val grid_rows_2 : t
(** 2 grid rows. *)

val grid_rows_3 : t
(** 3 grid rows. *)

val grid_rows_4 : t
(** 4 grid rows. *)

val grid_rows_5 : t
(** 5 grid rows. *)

val grid_rows_6 : t
(** 6 grid rows. *)

val static : t
(** Static positioning. *)

val relative : t
(** Position relative. *)

val absolute : t
(** Position absolute. *)

val fixed : t
(** Position fixed. *)

val sticky : t
(** Position sticky. *)

val inset_0 : t
(** Set all inset values to 0. *)

val inset_x_0 : t
(** Set left and right to 0. *)

val inset_y_0 : t
(** Set top and bottom to 0. *)

val top : int -> t
(** [top n] sets top position value. *)

val right : int -> t
(** [right n] sets right position value. *)

val bottom : int -> t
(** [bottom n] sets bottom position value. *)

val left : int -> t
(** [left n] sets left position value. *)

val z : int -> t
(** [z n] sets z-index value. *)

val z_10 : t
(** Z-index of 10. *)

(** {1 Typography}
    @see <https://tailwindcss.com/docs/font-size> Typography *)

val text_xs : t
(** Extra small text size (0.75rem). *)

val text_sm : t
(** Small text size (0.875rem). *)

val text_base : t
(** Base text size (1rem). *)

val text_lg : t
(** Large text size (1.125rem). *)

val text_xl : t
(** Extra large text size (1.25rem). *)

val text_2xl : t
(** 2x large text size (1.5rem). *)

val text_3xl : t
(** 3x large text size (1.875rem). *)

val text_4xl : t
(** 4x large text size (2.25rem). *)

val text_5xl : t
(** 5x large text size (3rem). *)

val font_thin : t
(** Font weight 100. *)

val font_light : t
(** Font weight 300. *)

val font_normal : t
(** Font weight 400. *)

val font_medium : t
(** Font weight 500. *)

val font_semibold : t
(** Font weight 600. *)

val font_bold : t
(** Font weight 700. *)

val font_extrabold : t
(** Font weight 800. *)

val font_black : t
(** Font weight 900. *)

val italic : t
(** Italic text style. *)

val not_italic : t
(** Remove italic text style. *)

val underline : t
(** Underlined text decoration. *)

val line_through : t
(** Line-through text decoration. *)

val no_underline : t
(** Remove text decoration. *)

val text_left : t
(** Left-aligned text. *)

val text_center : t
(** Center-aligned text. *)

val text_right : t
(** Right-aligned text. *)

val text_justify : t
(** Justified text. *)

val leading_none : t
(** Line height of 1. *)

val leading_tight : t
(** Line height of 1.25. *)

val leading_snug : t
(** Line height of 1.375. *)

val leading_normal : t
(** Line height of 1.5. *)

val leading_relaxed : t
(** Line height of 1.625. *)

val leading_loose : t
(** Line height of 2. *)

val leading_6 : t
(** Line height of 1.5rem. *)

val tracking_tighter : t
(** Letter spacing of -0.05em. *)

val tracking_tight : t
(** Letter spacing of -0.025em. *)

val tracking_normal : t
(** Letter spacing of 0. *)

val tracking_wide : t
(** Letter spacing of 0.025em. *)

val tracking_wider : t
(** Letter spacing of 0.05em. *)

val tracking_widest : t
(** Letter spacing of 0.1em. *)

val whitespace_normal : t
(** Normal whitespace handling. *)

val whitespace_nowrap : t
(** Prevent text wrapping. *)

val whitespace_pre : t
(** Preserve whitespace. *)

val whitespace_pre_line : t
(** Preserve line breaks. *)

val whitespace_pre_wrap : t
(** Preserve whitespace and wrap. *)

val antialiased : t
(** Antialiased font smoothing. *)

val sm_text_2xl : t
(** 2x large text on small screens. *)

val sm_text_4xl : t
(** 4x large text on small screens. *)

val sm_text_5xl : t
(** 5x large text on small screens. *)

val sm_flex_row : t
(** Flex row on small screens. *)

(** {1 Borders}
    @see <https://tailwindcss.com/docs/border-width> Borders *)

val border : t
(** Default border. *)

val border_t : t
(** Top border. *)

val border_r : t
(** Right border. *)

val border_b : t
(** Bottom border. *)

val border_l : t
(** Left border. *)

val border_0 : t
(** No border width. *)

val border_2 : t
(** Border width of 2px. *)

val border_4 : t
(** Border width of 4px. *)

val border_8 : t
(** Border width of 8px. *)

val rounded : rounded -> t
(** [rounded r] sets border radius using the rounded scale. *)

val rounded_none : t
(** No border radius. *)

val rounded_sm : t
(** Small border radius (0.125rem). *)

val rounded_lg : t
(** Large border radius (0.5rem). *)

val rounded_xl : t
(** Extra large border radius (0.75rem). *)

val rounded_2xl : t
(** 2x large border radius (1rem). *)

val rounded_3xl : t
(** 3x large border radius (1.5rem). *)

val rounded_full : t
(** Full border radius (9999px). *)

val border_collapse : t
(** Collapse table borders. *)

val border_separate : t
(** Separate table borders. *)

val border_spacing : int -> t
(** [border_spacing n] sets border spacing using spacing scale. *)

val border_spacing_0 : t
(** No border spacing. *)

val border_spacing_1 : t
(** Border spacing of 0.25rem. *)

val border_spacing_2 : t
(** Border spacing of 0.5rem. *)

val border_spacing_4 : t
(** Border spacing of 1rem. *)

val border_spacing_8 : t
(** Border spacing of 2rem. *)

(** {1 Effects & Filters}
    @see <https://tailwindcss.com/docs/box-shadow> Effects
    @see <https://tailwindcss.com/docs/blur> Filters
    @see <https://tailwindcss.com/docs/backdrop-blur> Backdrop Filters *)

val shadow : shadow -> t
(** [shadow s] sets box shadow using the shadow scale. *)

val shadow_sm : t
(** Small box shadow. *)

val shadow_md : t
(** Medium box shadow. *)

val shadow_lg : t
(** Large box shadow. *)

val shadow_xl : t
(** Extra large box shadow. *)

val shadow_2xl : t
(** 2x large box shadow. *)

val shadow_inner : t
(** Inner box shadow. *)

val shadow_none : t
(** Remove box shadow. *)

val opacity : int -> t
(** [opacity n] sets opacity (0-100). *)

val opacity_10 : t
(** 10% opacity. *)

val opacity_25 : t
(** 25% opacity. *)

val opacity_30 : t
(** 30% opacity. *)

val opacity_50 : t
(** 50% opacity. *)

val hover_opacity_70 : t
(** 70% opacity on hover. *)

val outline_none : t
(** Remove outline. *)

val ring : t
(** Default focus ring. *)

val ring_0 : t
(** No focus ring. *)

val ring_1 : t
(** 1px focus ring. *)

val ring_2 : t
(** 2px focus ring. *)

val ring_4 : t
(** 4px focus ring. *)

val ring_8 : t
(** 8px focus ring. *)

val ring_offset_2 : t
(** 2px ring offset. *)

val ring_white : t
(** White focus ring. *)

val isolate : t
(** Isolate element for stacking context. *)

val blur_none : t
(** No blur effect. *)

val blur_sm : t
(** Small blur (4px). *)

val blur : t
(** Default blur (8px). *)

val blur_md : t
(** Medium blur (12px). *)

val blur_lg : t
(** Large blur (16px). *)

val blur_xl : t
(** Extra large blur (24px). *)

val blur_2xl : t
(** 2x large blur (40px). *)

val blur_3xl : t
(** 3x large blur (64px). *)

val brightness : int -> t
(** [brightness n] sets brightness filter (0-200, where 100 is normal). *)

val brightness_0 : t
(** 0% brightness (black). *)

val brightness_50 : t
(** 50% brightness. *)

val brightness_75 : t
(** 75% brightness. *)

val brightness_90 : t
(** 90% brightness. *)

val brightness_95 : t
(** 95% brightness. *)

val brightness_100 : t
(** 100% brightness (normal). *)

val brightness_105 : t
(** 105% brightness. *)

val brightness_110 : t
(** 110% brightness. *)

val brightness_125 : t
(** 125% brightness. *)

val brightness_150 : t
(** 150% brightness. *)

val brightness_200 : t
(** 200% brightness. *)

val contrast : int -> t
(** [contrast n] sets contrast filter (0-200, where 100 is normal). *)

val contrast_0 : t
(** 0% contrast. *)

val contrast_50 : t
(** 50% contrast. *)

val contrast_75 : t
(** 75% contrast. *)

val contrast_100 : t
(** 100% contrast (normal). *)

val contrast_125 : t
(** 125% contrast. *)

val contrast_150 : t
(** 150% contrast. *)

val contrast_200 : t
(** 200% contrast. *)

val grayscale_0 : t
(** No grayscale (full color). *)

val grayscale : t
(** Full grayscale. *)

val backdrop_blur_none : t
(** No backdrop blur. *)

val backdrop_blur_sm : t
(** Small backdrop blur (4px). *)

val backdrop_blur : t
(** Default backdrop blur (8px). *)

val backdrop_blur_md : t
(** Medium backdrop blur (12px). *)

val backdrop_blur_lg : t
(** Large backdrop blur (16px). *)

val backdrop_blur_xl : t
(** Extra large backdrop blur (24px). *)

val backdrop_blur_2xl : t
(** 2x large backdrop blur (40px). *)

val backdrop_blur_3xl : t
(** 3x large backdrop blur (64px). *)

val backdrop_brightness : int -> t
(** [backdrop_brightness n] sets backdrop brightness filter (0-200, where 100 is
    normal). *)

val backdrop_brightness_0 : t
(** 0% backdrop brightness (black). *)

val backdrop_brightness_50 : t
(** 50% backdrop brightness. *)

val backdrop_brightness_75 : t
(** 75% backdrop brightness. *)

val backdrop_brightness_90 : t
(** 90% backdrop brightness. *)

val backdrop_brightness_95 : t
(** 95% backdrop brightness. *)

val backdrop_brightness_100 : t
(** 100% backdrop brightness (normal). *)

val backdrop_brightness_105 : t
(** 105% backdrop brightness. *)

val backdrop_brightness_110 : t
(** 110% backdrop brightness. *)

val backdrop_brightness_125 : t
(** 125% backdrop brightness. *)

val backdrop_brightness_150 : t
(** 150% backdrop brightness. *)

val backdrop_brightness_200 : t
(** 200% backdrop brightness. *)

val backdrop_contrast : int -> t
(** [backdrop_contrast n] sets backdrop contrast filter (0-200, where 100 is
    normal). *)

val backdrop_contrast_0 : t
(** 0% backdrop contrast. *)

val backdrop_contrast_50 : t
(** 50% backdrop contrast. *)

val backdrop_contrast_75 : t
(** 75% backdrop contrast. *)

val backdrop_contrast_100 : t
(** 100% backdrop contrast (normal). *)

val backdrop_contrast_125 : t
(** 125% backdrop contrast. *)

val backdrop_contrast_150 : t
(** 150% backdrop contrast. *)

val backdrop_contrast_200 : t
(** 200% backdrop contrast. *)

val backdrop_grayscale_0 : t
(** No backdrop grayscale (full color). *)

val backdrop_grayscale : t
(** Full backdrop grayscale. *)

val backdrop_opacity : int -> t
(** [backdrop_opacity n] sets backdrop opacity filter (0-100). *)

val backdrop_saturate : int -> t
(** [backdrop_saturate n] sets backdrop saturation filter (0-200, where 100 is
    normal). *)

val backdrop_saturate_0 : t
(** 0% backdrop saturation. *)

val backdrop_saturate_50 : t
(** 50% backdrop saturation. *)

val backdrop_saturate_100 : t
(** 100% backdrop saturation (normal). *)

val backdrop_saturate_150 : t
(** 150% backdrop saturation. *)

val backdrop_saturate_200 : t
(** 200% backdrop saturation. *)

(** {1 Transitions & Animations}
    @see <https://tailwindcss.com/docs/animation> Animations *)

val transition_none : t
(** No transition. *)

val transition_all : t
(** Transition all properties. *)

val transition_colors : t
(** Transition color properties. *)

val transition_opacity : t
(** Transition opacity. *)

val transition_shadow : t
(** Transition box shadow. *)

val transition_transform : t
(** Transition transform. *)

val scale : int -> t
(** [scale n] sets scale transformation (percentage, e.g., 105 for scale-105).
*)

val scale_150 : t
(** Scale to 150%. *)

val rotate : int -> t
(** [rotate n] sets rotate transformation (degrees). *)

val translate_x : int -> t
(** [translate_x n] sets horizontal translation. *)

val translate_y : int -> t
(** [translate_y n] sets vertical translation. *)

val transform : t
(** Enable transform utilities. *)

val transform_none : t
(** Disable transforms. *)

val transform_gpu : t
(** Use GPU acceleration for transforms. *)

val sm_transform_none : t
(** Remove transform on small screens. *)

val animate_none : t
(** No animation. *)

val animate_spin : t
(** Spin animation (1s linear infinite). *)

val animate_ping : t
(** Ping animation (1s cubic-bezier infinite). *)

val animate_pulse : t
(** Pulse animation (2s cubic-bezier infinite). *)

val animate_bounce : t
(** Bounce animation (1s infinite). *)

(** {1 Tables}
    @see <https://tailwindcss.com/docs/table-layout> Tables *)

val table_auto : t
(** Automatic table layout. *)

val table_fixed : t
(** Fixed table layout. *)

(** {1 Forms}
    @see <https://github.com/tailwindlabs/tailwindcss-forms> Forms Plugin *)

val form_input : t
(** Base styles for input elements. *)

val form_textarea : t
(** Base styles for textarea elements. *)

val form_select : t
(** Base styles for select elements. *)

val form_checkbox : t
(** Base styles for checkbox inputs. *)

val form_radio : t
(** Base styles for radio inputs. *)

val focus_ring : t
(** Focus ring utility (3px). *)

val focus_ring_2 : t
(** Focus ring utility (2px). *)

val focus_ring_blue_500 : t
(** Blue focus ring color. *)

val focus_border_blue_500 : t
(** Blue focus border color. *)

(** {1 Interactivity & Scroll}
    @see <https://tailwindcss.com/docs/scroll-snap-type> Scroll Snap *)

val cursor_auto : t
(** Automatic cursor. *)

val cursor_default : t
(** Default cursor. *)

val cursor_pointer : t
(** Pointer cursor. *)

val cursor_wait : t
(** Wait cursor. *)

val cursor_move : t
(** Move cursor. *)

val cursor_not_allowed : t
(** Not-allowed cursor. *)

val select_none : t
(** Disable text selection. *)

val select_text : t
(** Enable text selection. *)

val select_all : t
(** Select all text on focus. *)

val select_auto : t
(** Automatic text selection. *)

val pointer_events_none : t
(** Disable pointer events. *)

val pointer_events_auto : t
(** Enable pointer events. *)

val overflow_auto : t
(** Automatic overflow handling. *)

val overflow_hidden : t
(** Hide overflow content. *)

val overflow_visible : t
(** Show overflow content. *)

val overflow_scroll : t
(** Always show scrollbars. *)

val overflow_x_auto : t
(** Auto horizontal overflow. *)

val overflow_x_hidden : t
(** Hide horizontal overflow. *)

val overflow_x_visible : t
(** Show horizontal overflow. *)

val overflow_x_scroll : t
(** Always show horizontal scrollbar. *)

val overflow_y_auto : t
(** Auto vertical overflow. *)

val overflow_y_hidden : t
(** Hide vertical overflow. *)

val overflow_y_visible : t
(** Show vertical overflow. *)

val overflow_y_scroll : t
(** Always show vertical scrollbar. *)

val snap_none : t
(** No scroll snapping. *)

val snap_x : t
(** Horizontal scroll snapping. *)

val snap_y : t
(** Vertical scroll snapping. *)

val snap_both : t
(** Both horizontal and vertical scroll snapping. *)

val snap_mandatory : t
(** Mandatory scroll snapping. *)

val snap_proximity : t
(** Proximity-based scroll snapping. *)

val snap_start : t
(** Snap to start of container. *)

val snap_end : t
(** Snap to end of container. *)

val snap_center : t
(** Snap to center of container. *)

val snap_align_none : t
(** No snap alignment. *)

val snap_normal : t
(** Normal snap stop behavior. *)

val snap_always : t
(** Always stop at snap positions. *)

val scroll_auto : t
(** Auto scroll behavior. *)

val scroll_smooth : t
(** Smooth scroll behavior. *)

val object_contain : t
(** Scale content to fit container. *)

val object_cover : t
(** Scale content to cover container. *)

val object_fill : t
(** Stretch content to fill container. *)

val object_none : t
(** Content retains original size. *)

val object_scale_down : t
(** Scale down content if needed. *)

val sr_only : t
(** Screen reader only (visually hidden). *)

val not_sr_only : t
(** Not screen reader only. *)

val line_clamp_1 : t
(** Clamp text to 1 line. *)

val line_clamp_2 : t
(** Clamp text to 2 lines. *)

val line_clamp_3 : t
(** Clamp text to 3 lines. *)

val line_clamp_4 : t
(** Clamp text to 4 lines. *)

val line_clamp_5 : t
(** Clamp text to 5 lines. *)

val line_clamp_6 : t
(** Clamp text to 6 lines. *)

val line_clamp_none : t
(** Remove line clamping. *)

(** {1 State & Responsive Modifiers} *)

val hover : t -> t
(** [hover style] applies style on hover. *)

val focus : t -> t
(** [focus style] applies style on focus. *)

val focus_visible : t
(** Focus-visible pseudo-class. *)

val active : t -> t
(** [active style] applies style on active state. *)

val disabled : t -> t
(** [disabled style] applies style when disabled. *)

val group_hover : t -> t
(** [group_hover style] applies style when parent group is hovered. *)

val group_focus : t -> t
(** [group_focus style] applies style when parent group is focused. *)

val dark : t -> t
(** [dark style] applies style in dark mode. *)

val sm : t -> t
(** [sm style] applies style on small screens and up (640px+). *)

val md : t -> t
(** [md style] applies style on medium screens and up (768px+). *)

val lg : t -> t
(** [lg style] applies style on large screens and up (1024px+). *)

val xl : t -> t
(** [xl style] applies style on extra large screens and up (1280px+). *)

val xl2 : t -> t
(** [xl2 style] applies style on 2x large screens and up (1536px+). *)

val md_block : t
(** Block display on medium screens. *)

val peer : t
(** Marker class for peer relationships. *)

val group : t
(** Marker class for group relationships. *)

val peer_hover : t -> t
(** [peer_hover style] applies style when a sibling peer element is hovered. *)

val peer_focus : t -> t
(** [peer_focus style] applies style when a sibling peer element is focused. *)

val peer_checked : t -> t
(** [peer_checked style] applies style when a sibling peer checkbox/radio is
    checked. *)

val aria_checked : t -> t
(** [aria_checked style] applies style when aria-checked="true". *)

val aria_expanded : t -> t
(** [aria_expanded style] applies style when aria-expanded="true". *)

val aria_selected : t -> t
(** [aria_selected style] applies style when aria-selected="true". *)

val aria_disabled : t -> t
(** [aria_disabled style] applies style when aria-disabled="true". *)

(** {1 Prose Typography}
    @see <https://tailwindcss.com/docs/typography-plugin> Typography Plugin *)

val prose : t
(** Default prose styling. *)

val prose_sm : t
(** Small prose styling. *)

val prose_lg : t
(** Large prose styling. *)

val prose_xl : t
(** Extra large prose styling. *)

val prose_gray : t
(** Gray prose styling. *)

(** {1 Class Generation & Internals} *)

val to_class : t -> string
(** [to_class style] generates a class name from a style. *)

val to_classes : t list -> string
(** [to_classes styles] generates a space-separated string of class names from a
    list of styles. *)

val to_string : t -> string
(** [to_string style] converts a single style to a class string. *)

val classes_to_string : t list -> string
(** [classes_to_string styles] is an alias for to_classes. *)

val to_css_properties : t -> Css.property list
(** [to_css_properties style] converts a Tw style to CSS property-value pairs.
*)

val to_css_rule : selector:string -> t list -> Css.rule
(** [to_css_rule ~selector styles] converts a list of Tw styles to a CSS rule
    with given selector. *)

val to_stylesheet : (string * t list) list -> Css.stylesheet
(** [to_stylesheet pairs] generates a stylesheet from a list of (selector,
    styles) pairs. *)

val of_tw : t list -> Css.stylesheet
(** [of_tw styles] generates CSS stylesheet for a list of Tw classes. *)

val color_to_string : color -> string
(** [color_to_string c] converts a color to its string representation. *)

val spacing_to_class_suffix : int -> string
(** [spacing_to_class_suffix n] converts spacing integer to its class suffix. *)

val pp : t Core.Pp.t
(** [pp t] pretty-prints Tailwind class [t]. *)

val aspect_ratio : float -> float -> t
(** [aspect_ratio width height] sets custom aspect ratio (e.g., aspect_ratio
    1318. 752.). *)

val clip_path : string -> t
(** [clip_path value] sets custom clip-path for complex shapes. *)
