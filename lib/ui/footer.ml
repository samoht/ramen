open Html
open Tw

let social_icon label =
  match String.lowercase_ascii label with
  | "github" -> Icon.github
  | "twitter" -> Icon.twitter
  | "bluesky" -> Icon.bluesky
  | "rss" -> Icon.rss
  | _ -> span []

(* Render contact information and copyright *)
let render_contact_info ~site ~palette =
  div
    ~tw:[ flex; flex_col; gap (int 2) ]
    [
      a
        ~at:[ At.href ("mailto:" ^ site.Core.Site.author_email) ]
        ~tw:
          [
            Colors.text_muted palette;
            on_hover [ Colors.text_primary palette ];
            transition_colors;
          ]
        [ txt site.Core.Site.author_email ];
      Html.p
        ~tw:[ text_xs; text ~shade:400 palette.Colors.neutral ]
        [ raw site.Core.Site.footer.Core.Site.copyright ];
    ]

(* Render footer links (privacy, terms, etc.) *)
let render_footer_links ~palette links =
  div
    ~tw:[ flex; items_center; gap (int 4) ]
    (List.map
       (fun (link : Core.Site.link) ->
         a
           ~at:[ At.href link.href ]
           ~tw:
             [
               Colors.text_muted palette;
               on_hover [ Colors.text_primary palette ];
               transition_colors;
             ]
           [ txt link.text ])
       links)

(* Render social media icons *)
let render_social_icons ~palette social =
  match social with
  | None -> div []
  | Some social ->
      let links = [] in
      let links =
        match social.Core.Site.twitter with
        | Some handle ->
            ( "https://twitter.com/"
              ^ String.sub handle 1 (String.length handle - 1),
              "twitter" )
            :: links
        | None -> links
      in
      let links =
        match social.Core.Site.github with
        | Some username -> ("https://github.com/" ^ username, "github") :: links
        | None -> links
      in
      let links =
        match social.Core.Site.linkedin with
        | Some username ->
            ("https://linkedin.com/in/" ^ username, "linkedin") :: links
        | None -> links
      in
      div
        ~tw:[ flex; items_center; gap (int 4) ]
        (List.map
           (fun (url, icon_name) ->
             a
               ~at:[ At.href url; At.target "_blank"; At.rel "noopener" ]
               ~tw:
                 [
                   Colors.text_muted palette;
                   on_hover [ Colors.text_primary palette ];
                   transition_colors;
                 ]
               [ social_icon icon_name ])
           links)

type t = { site : Core.Site.t; palette : Colors.palette }
(** Component data for the footer *)

let render t =
  let site = t.site in
  let palette = t.palette in
  footer
    ~at:[ At.id "footer" ]
    ~tw:
      [
        border_t;
        Colors.border_muted palette;
        py (int 8);
        Colors.bg_primary palette;
      ]
    [
      div
        ~tw:[ max_w (rem 56.0) (* 4xl = 56rem *); mx auto; px (int 6) ]
        [
          div
            ~tw:
              [
                flex;
                flex_col;
                on_sm [ flex_row ];
                justify_between;
                items_center;
                gap (int 4);
                text_sm;
              ]
            [
              render_contact_info ~site ~palette;
              div
                ~tw:[ flex; flex_col; on_sm [ flex_row ]; gap (int 4) ]
                [
                  render_footer_links ~palette
                    site.Core.Site.footer.Core.Site.links;
                  render_social_icons ~palette site.Core.Site.social;
                ];
            ];
        ];
    ]

let pp t =
  Core.Pp.record
    [ ("site", Core.Site.pp t.site); ("palette", Colors.pp_palette t.palette) ]
