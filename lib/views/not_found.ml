open Ui
open Html
open Tw

let page =
  div
    ~tw:[ text_center; min_h screen; pt (int 56) ]
    [
      Html.p ~tw:[ text_base; font_semibold; text ~shade:600 sky ] [ txt "404" ];
      h1
        ~tw:
          [
            mt (int 4);
            text_3xl;
            font_bold;
            tracking_tight;
            text ~shade:900 gray;
            on_sm [ text_5xl ];
          ]
        [ txt "Page not found" ];
      Html.p
        ~tw:[ mt (int 6); text_base; leading_relaxed; text ~shade:600 gray ]
        [ txt "Sorry, we couldn't find the page you're looking for." ];
      div
        ~tw:[ mt (int 10); flex; items_center; justify_center; gap_x (int 6) ]
        [ Ui.Button.render ~href:"/" "Go back home" ];
    ]

let title = "404: Page Not Found"

let render ~site =
  Ui.Layout.render ~title ~site Core.Page.Error
    [ Ui.Section.render ~py:`None ~width:`Large [ page ] ]

let file = __FILE__
