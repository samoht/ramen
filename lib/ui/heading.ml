open Html

let mk_id = function None -> [] | Some i -> [ At.id i ]

let h1' ?color ?clamp ?padding ?id ~palette node =
  let color_class =
    match color with
    | None | Some `Normal -> Colors.text_primary palette
    | Some `Light -> Tw.text_white
  in
  let padding =
    match padding with
    | None | Some `Normal -> Tw.pb_12
    | Some `Small -> Tw.pb_8
  in
  let id_attrs = mk_id id in
  let offset =
    match id with None -> [] | Some _ -> [ Tw.pt_56; Tw.neg_mt_56 ]
  in
  let clamp_classes =
    match clamp with
    | None -> []
    | Some 1 -> [ Tw.line_clamp_1 ]
    | Some 2 -> [ Tw.line_clamp_2 ]
    | Some 3 -> [ Tw.line_clamp_3 ]
    | Some 4 -> [ Tw.line_clamp_4 ]
    | Some 5 -> [ Tw.line_clamp_5 ]
    | Some 6 -> [ Tw.line_clamp_6 ]
    | Some _ -> []
  in
  h1 ~at:id_attrs
    ~tw:
      ([
         Tw.text_4xl;
         Tw.font_bold;
         Tw.tracking_tight;
         Tw.sm_text_5xl;
         padding;
         color_class;
       ]
      @ offset @ clamp_classes)
    node

let h2' ?color ?clamp ?padding ?id ~palette node =
  let color_class =
    match color with
    | None | Some `Normal -> Colors.text_primary palette
    | Some `Light -> Tw.text_white
  in
  let padding =
    match padding with None | Some `Normal -> Tw.pb_8 | Some `Small -> Tw.pb_4
  in
  let id_attrs = mk_id id in
  let offset =
    match id with None -> [] | Some _ -> [ Tw.pt_56; Tw.neg_mt_56 ]
  in
  let clamp_classes =
    match clamp with
    | None -> []
    | Some 1 -> [ Tw.line_clamp_1 ]
    | Some 2 -> [ Tw.line_clamp_2 ]
    | Some 3 -> [ Tw.line_clamp_3 ]
    | Some 4 -> [ Tw.line_clamp_4 ]
    | Some 5 -> [ Tw.line_clamp_5 ]
    | Some 6 -> [ Tw.line_clamp_6 ]
    | Some _ -> []
  in
  h2 ~at:id_attrs
    ~tw:
      ([
         Tw.text_3xl;
         Tw.font_bold;
         Tw.tracking_tight;
         Tw.sm_text_4xl;
         padding;
         color_class;
       ]
      @ offset @ clamp_classes)
    node

let h3' ?color ?clamp ?padding ?id ~palette node =
  let color_class =
    match color with
    | None | Some `Normal -> Colors.text_primary palette
    | Some `Light -> Tw.text_white
  in
  let padding =
    match padding with None | Some `Normal -> Tw.pb_4 | Some `Small -> Tw.pb_2
  in
  let id_attrs = mk_id id in
  let offset =
    match id with None -> [] | Some _ -> [ Tw.pt_56; Tw.neg_mt_56 ]
  in
  let clamp_classes =
    match clamp with
    | None -> []
    | Some 1 -> [ Tw.line_clamp_1 ]
    | Some 2 -> [ Tw.line_clamp_2 ]
    | Some 3 -> [ Tw.line_clamp_3 ]
    | Some 4 -> [ Tw.line_clamp_4 ]
    | Some 5 -> [ Tw.line_clamp_5 ]
    | Some 6 -> [ Tw.line_clamp_6 ]
    | Some _ -> []
  in
  h3 ~at:id_attrs
    ~tw:
      ([
         Tw.text_xl;
         Tw.font_bold;
         Tw.tracking_tight;
         Tw.sm_text_2xl;
         padding;
         color_class;
       ]
      @ offset @ clamp_classes)
    node

let h4' ?color ?clamp ?padding ?id ~palette node =
  let color_class =
    match color with
    | None | Some `Normal -> Colors.text_primary palette
    | Some `Light -> Tw.text_white
  in
  let padding =
    match padding with None | Some `Normal -> Tw.pb_4 | Some `Small -> Tw.pb_2
  in
  let id_attrs = mk_id id in
  let offset =
    match id with None -> [] | Some _ -> [ Tw.pt_56; Tw.neg_mt_56 ]
  in
  let clamp_classes =
    match clamp with
    | None -> []
    | Some 1 -> [ Tw.line_clamp_1 ]
    | Some 2 -> [ Tw.line_clamp_2 ]
    | Some 3 -> [ Tw.line_clamp_3 ]
    | Some 4 -> [ Tw.line_clamp_4 ]
    | Some 5 -> [ Tw.line_clamp_5 ]
    | Some 6 -> [ Tw.line_clamp_6 ]
    | Some _ -> []
  in
  h4 ~at:id_attrs
    ~tw:
      ([ Tw.text_lg; Tw.font_bold; Tw.tracking_tight; padding; color_class ]
      @ offset @ clamp_classes)
    node

let h1 ?color ?clamp ?padding ?id ~palette str =
  h1' ?color ?clamp ?padding ?id ~palette [ txt str ]

let h2 ?color ?clamp ?padding ?id ~palette str =
  h2' ?color ?clamp ?padding ?id ~palette [ txt str ]

let h3 ?color ?clamp ?padding ?id ~palette str =
  h3' ?color ?clamp ?padding ?id ~palette [ txt str ]

let h4 ?color ?clamp ?padding ?id ~palette str =
  h4' ?color ?clamp ?padding ?id ~palette [ txt str ]
