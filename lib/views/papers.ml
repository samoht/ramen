(** Papers/publications page *)

module F = Fmt
open Ui
open Html
open Tw
module Fmt = F

let file = "papers.ml"

(* Helper to render paper venue and year *)
let render_venue paper =
  Html.p
    ~tw:[ text_sm; text ~shade:600 gray; mb (int 2) ]
    [
      Html.txt (Fmt.str "%s (%s)" paper.Core.Paper.where paper.Core.Paper.year);
    ]

(* Helper to render authors list *)
let render_authors authors =
  let author_names =
    authors
    |> List.map (fun (a : Core.Paper.author) -> a.name)
    |> String.concat ", "
  in
  div
    ~tw:[ text_sm; text ~shade:700 gray; mb (int 4) ]
    [ Html.txt "Authors: "; Html.txt author_names ]

(* Helper to render abstract if present *)
let render_abstract = function
  | None -> Html.empty
  | Some abstract ->
      div
        ~tw:[ text ~shade:700 gray; mb (int 4) ]
        [ Html.p [ Html.txt abstract ] ]

(* Helper to render file links *)
let render_files files =
  if files = [] then Html.empty
  else
    div
      ~tw:[ flex; gap (int 4) ]
      (List.map
         (fun (file : Core.Paper.file) ->
           a
             ~at:[ At.href file.url ]
             ~tw:
               [
                 text ~shade:600 blue;
                 on_hover [ text ~shade:800 blue ];
                 underline;
               ]
             [ Html.txt file.name ])
         files)

(* Helper to render a single paper *)
let render_paper ~palette paper =
  article
    ~tw:[ bg white; p (int 6); rounded lg; shadow md ]
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
             Html.p
               ~tw:[ text ~shade:600 gray; italic ]
               [ Html.txt "No papers available at this time." ]
           else
             Html.div
               ~tw:[ flex; flex_col; gap (int 8) ]
               (List.map
                  (render_paper ~palette:Ui.Colors.default_palette)
                  papers));
        ];
    ]
