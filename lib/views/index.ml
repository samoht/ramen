open Ui
open Html.At
open Tw

(* Helper to take first n elements from a list *)
let take n list =
  let rec aux n acc = function
    | [] -> List.rev acc
    | _ when n <= 0 -> List.rev acc
    | h :: t -> aux (n - 1) (h :: acc) t
  in
  aux n [] list

(* Render post title and description *)
let render_post_content (post : Core.Blog.t) =
  Html.div ~tw:[ flex_1 ]
    [
      Html.h3
        ~tw:
          [
            text_lg;
            font_semibold;
            text ~shade:900 gray;
            on_group_hover [ text ~shade:700 sky ];
            transition_colors;
            mb (int 2);
          ]
        [ Html.txt post.title ];
      Html.p
        ~tw:[ text_sm; text ~shade:600 gray; leading_relaxed ]
        [ Html.txt post.description ];
    ]

(* Render post date *)
let render_post_date post =
  Html.time
    ~at:[ datetime (Core.Blog.date post) ]
    ~tw:[ text_sm; text ~shade:500 gray; whitespace_nowrap ]
    [ Html.txt (Core.Blog.pretty_date post) ]

(* Render a single blog post preview *)
let render_post_preview (post : Core.Blog.t) =
  Html.article
    ~tw:
      [
        group;
        bg white;
        p (int 6);
        rounded lg;
        border `Default;
        border_color ~shade:200 gray;
        on_hover [ shadow lg; border_color ~shade:300 gray ];
        transition_all;
      ]
    [
      Html.a
        ~at:[ href (Fmt.str "/blog/%s/" post.slug) ]
        ~tw:[ block; group ]
        [
          Html.div
            ~tw:[ flex; flex_col; on_sm [ flex_row ]; gap (int 4) ]
            [ render_post_content post; render_post_date post ];
        ];
    ]

(* Render recent posts section *)
let render_recent_posts recent_posts =
  if List.length recent_posts = 0 then Html.empty
  else
    Html.section
      ~tw:[ py (int 8); bg ~shade:50 gray ]
      [
        Html.div
          ~tw:[ max_w (rem 56.0) (* 4xl = 56rem *); mx auto; px (int 6) ]
          [
            Html.div
              ~tw:[ border_t; border_color ~shade:200 gray; pt (int 8) ]
              [
                Html.h2
                  ~tw:
                    [
                      on_sm [ text_2xl ];
                      font_bold;
                      text ~shade:900 gray;
                      mb (int 6);
                    ]
                  [ Html.txt "Recent Writing" ];
                Html.div
                  ~tw:[ flex; flex_col; gap (int 4) ]
                  (List.map render_post_preview recent_posts);
                Html.div
                  ~tw:[ mt (int 6) ]
                  [
                    Html.a
                      ~at:[ href "/blog/" ]
                      ~tw:
                        [
                          inline_flex;
                          items_center;
                          text_sm;
                          text ~shade:700 gray;
                          font_medium;
                          on_hover [ text ~shade:900 gray ];
                          transition_colors;
                        ]
                      [
                        Html.txt "View all posts";
                        Html.span ~tw:[ ml (int 1) ] [ Html.txt "→" ];
                      ];
                  ];
              ];
          ];
      ]

(* Render markdown content section *)
let render_content_section page =
  Html.section
    ~tw:[ pt (int 8); pb (int 8); bg white ]
    [
      Html.div
        ~tw:[ max_w (rem 56.0) (* 4xl = 56rem *); mx auto; px (int 6) ]
        [
          Html.div
            ~tw:[ prose; prose_sm; max_w none ]
            [ Html.raw page.Core.Static.body_html ];
        ];
    ]

(* Main render function *)
let render ~site ~static_pages ~blog_posts =
  let static_page =
    List.find_opt (fun p -> p.Core.Static.name = "index") static_pages
  in
  let recent_posts = take 2 blog_posts in

  match static_page with
  | None ->
      (* Fallback if no index.md exists *)
      Ui.Layout.render ~title:site.Core.Site.name
        ~description:site.Core.Site.description ~site Core.Page.Index
        [
          Ui.Hero.render
            {
              style = Some Gradient;
              title = site.Core.Site.name;
              description = site.Core.Site.tagline;
              subtitle = None;
              palette = Ui.Colors.default_palette;
            };
          render_recent_posts recent_posts;
        ]
  | Some page ->
      (* Use content from index.md *)
      let description = Option.value ~default:"" page.description in
      Ui.Layout.render ~title:page.title ~description ~site Core.Page.Index
        [
          Ui.Hero.render
            {
              style = Some Gradient;
              title = page.title;
              description = site.Core.Site.tagline;
              subtitle = None;
              palette = Ui.Colors.default_palette;
            };
          render_content_section page;
          render_recent_posts recent_posts;
        ]

let file = __FILE__
