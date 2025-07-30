(** Papers/publications page *)

module F = Fmt
open Ui
open Html
module Fmt = F

let file = "papers.ml"

(* Helper to render paper venue and year *)
let render_venue paper =
  p
    ~tw:[ Tw.text_sm; Tw.text_gray_600; Tw.mb (Int 2) ]
    [ txt (Fmt.str "%s (%s)" paper.Core.Paper.where paper.Core.Paper.year) ]

(* Helper to render authors list *)
let render_authors authors =
  let author_names =
    authors
    |> List.map (fun (a : Core.Paper.author) -> a.name)
    |> String.concat ", "
  in
  div
    ~tw:[ Tw.text_sm; Tw.text_gray_700; Tw.mb (Int 4) ]
    [ txt "Authors: "; txt author_names ]

(* Helper to render abstract if present *)
let render_abstract = function
  | None -> void
  | Some abstract ->
      div ~tw:[ Tw.text_gray_700; Tw.mb (Int 4) ] [ p [ txt abstract ] ]

(* Helper to render file links *)
let render_files files =
  if files = [] then void
  else
    div
      ~tw:[ Tw.flex; Tw.gap (Int 4) ]
      (List.map
         (fun (file : Core.Paper.file) ->
           a
             ~at:[ At.href file.url ]
             ~tw:
               [
                 Tw.text ~shade:600 Tw.Blue;
                 Tw.hover (Tw.text ~shade:800 Tw.Blue);
                 Tw.underline;
               ]
             [ txt file.name ])
         files)

(* Helper to render a single paper *)
let render_paper ~palette paper =
  article
    ~tw:[ Tw.bg_white; Tw.p (Int 6); Tw.rounded_lg; Tw.shadow_md ]
    [
      Heading.h2 ~palette paper.Core.Paper.title;
      render_venue paper;
      render_authors paper.Core.Paper.authors;
      render_abstract paper.Core.Paper.abstract;
      render_files paper.Core.Paper.files;
    ]

let render ~site ~papers =
  let page_title = "Papers & Publications" in
  let description = "Research papers and publications" in

  Layout.render ~site ~title:page_title ~description Core.Page.Papers
    [
      Section.render
        [
          Heading.h1 ~palette:Ui.Colors.default_palette page_title;
          (if papers = [] then
             p
               ~tw:[ Tw.text_gray_600; Tw.italic ]
               [ txt "No papers available at this time." ]
           else
             div
               ~tw:[ Tw.space_y (Int 8) ]
               (List.map
                  (render_paper ~palette:Ui.Colors.default_palette)
                  papers));
        ];
    ]
