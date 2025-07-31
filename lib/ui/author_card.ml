open Core
open Html
open Tw

let render (b : Blog.author) =
  let author =
    match b with
    | Blog.Author a -> a
    | Blog.Name { name; _ } ->
        (* Create a minimal author record for names *)
        {
          Author.name;
          title = None;
          hidden = true;
          avatar = None;
          slug = "";
          aliases = [];
          homepage = None;
        }
  in
  let avatar =
    Avatar.render { size = None; opacity = None; ring = None; author }
  in
  let title = match author.title with None -> [] | Some t -> [ txt t ] in
  div
    ~tw:[ relative; mt (int 2); flex; items_center; gap_x (int 4) ]
    [
      avatar;
      div ~tw:[ text_xs; leading_6 ]
        [
          Html.p ~tw:[ font_semibold; text ~shade:600 gray ] [ txt author.name ];
          Html.p ~tw:[ text ~shade:600 gray ] title;
        ];
    ]
