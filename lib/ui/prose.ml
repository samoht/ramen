open Tw

module D = struct
  let style_headings palette =
    [
      (* Prose heading styles - styled consistently with the design *)
      font_bold;
      Colors.text_primary palette;
      leading_tight;
    ]

  let style_code =
    [
      (* Prose code styles - monospace with background *)
      font_mono;
      text_sm;
      bg ~shade:100 gray;
      px (int 1);
      py (rem 0.25);
      rounded sm;
    ]

  let style_a palette =
    [
      (* Style links within prose content *)
      text ~shade:600 palette.Colors.primary;
      on_hover [ text ~shade:800 palette.Colors.primary ];
      underline;
      font_medium;
      transition_colors;
    ]

  let style palette = style_headings palette @ style_code @ style_a palette

  let gray_style palette =
    Colors.text_muted palette :: style palette (* TODO: Add prose_gray *)

  let white_style palette = style palette (* Prose invert not yet implemented *)
end

let tw_classes ?(size = `Normal) ?(padding = `None) ?(color = `Normal) ?clamp
    ~palette () =
  let base = [ prose ] in
  let clamp =
    match clamp with
    | None -> []
    | Some 2 -> [] (* [ line_clamp_2 ] *)
    | Some 3 -> [] (* [ line_clamp_3 ] *)
    | Some _ -> [] (* Add more line-clamp classes as needed *)
  in
  let size =
    match size with
    | `Normal -> [ prose_lg; max_w none ]
    | `Small -> [ prose; max_w none ] (* prose_base equivalent *)
    | `Very_small -> [ prose_sm; max_w none ]
  in
  let padding =
    match padding with
    | `None -> []
    | `Small -> [ my (int 4) ]
    | `Normal -> [ my (int 8) ]
  in
  let color =
    match color with
    | `Normal -> D.gray_style palette
    | `Light -> D.white_style palette
  in
  base @ color @ size @ padding @ clamp

let p ?size ?padding ?color ?clamp ~palette nodes =
  Html.p ~tw:(tw_classes ?size ?padding ?color ?clamp ~palette ()) nodes
