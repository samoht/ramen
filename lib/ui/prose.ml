open Html

module D = struct
  (* TODO: Add prose element modifiers when implemented *)
  let style_headings _palette = [ Tw.Prose.prose_headings_text_sky_900 ]
  let style_code = [] (* Tw.prose_code_font_medium *)

  let style_a =
    [ (* TODO: Add prose link styles when implemented *)
      (* Tw.prose_a_text_sky_800; *) ]

  let style palette = style_headings palette @ style_code @ style_a

  let gray_style palette =
    Colors.text_muted palette :: Tw.Prose.prose_gray :: style palette

  let white_style palette = (* Tw.prose_invert :: *) style palette
end

let tw_classes ?(size = `Normal) ?(padding = `None) ?(color = `Normal) ?clamp
    ~palette () =
  let base = [ Tw.Prose.prose ] in
  let clamp =
    match clamp with
    | None -> []
    | Some 2 -> [] (* [ Tw.line_clamp_2 ] *)
    | Some 3 -> [] (* [ Tw.line_clamp_3 ] *)
    | Some _ -> [] (* Add more line-clamp classes as needed *)
  in
  let size =
    match size with
    | `Normal -> [ Tw.Prose.prose_lg; Tw.max_w_none ]
    | `Small -> [ Tw.Prose.prose_base; Tw.max_w_none ]
    | `Very_small -> [ Tw.Prose.prose_sm; Tw.max_w_none ]
  in
  let padding =
    match padding with
    | `None -> []
    | `Small -> [ Tw.my (Int 4) ]
    | `Normal -> [ Tw.my (Int 8) ]
  in
  let color =
    match color with
    | `Normal -> D.gray_style palette
    | `Light -> D.white_style palette
  in
  base @ color @ size @ padding @ clamp

let p ?size ?padding ?color ?clamp ~palette nodes =
  p ~tw:(tw_classes ?size ?padding ?color ?clamp ~palette ()) nodes
