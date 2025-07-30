open Ui
open Html

let page =
  div
    ~tw:[ Tw.text_center; Tw.min_h_screen; Tw.pt_56 ]
    [
      p
        ~tw:[ Tw.text_base; Tw.font_semibold; Tw.text ~shade:600 Tw.Sky ]
        [ txt "404" ];
      h1
        ~tw:
          [
            Tw.mt (Tw.Int 4);
            Tw.text_3xl;
            Tw.font_bold;
            Tw.tracking_tight;
            Tw.text ~shade:900 Tw.Gray;
            Tw.sm Tw.text_5xl;
          ]
        [ txt "Page not found" ];
      p
        ~tw:
          [
            Tw.mt (Tw.Int 6);
            Tw.text_base;
            Tw.leading_relaxed;
            Tw.text ~shade:600 Tw.Gray;
          ]
        [ txt "Sorry, we couldn't find the page you're looking for." ];
      div
        ~tw:
          [
            Tw.mt (Tw.Int 10);
            Tw.flex;
            Tw.items_center;
            Tw.justify_center;
            Tw.gap_x (Tw.Int 6);
          ]
        [ Ui.Button.render ~href:"/" "Go back home" ];
    ]

let title = "404: Page Not Found"

let render ~site =
  Ui.Layout.render ~title ~site Core.Page.Error
    [ Ui.Section.render ~py:`None ~width:`Large [ page ] ]

let file = __FILE__
