(* Icon components for the site *)

open Html
open Tw

module D = struct
  let color palette = [ text white; bg ~shade:600 palette.Colors.primary ]
end

let _wrap ?(size = `Normal) palette icon =
  let size_classes =
    match size with
    | `Normal -> [ h (int 10); w (int 10) ]
    | `Small -> [ h (int 6); w (int 6) ]
  in
  let base_classes = [ p (int 1); rounded lg ] in
  div
    ~tw:(base_classes @ D.color palette @ size_classes)
    [
      div
        ~tw:[ flex; items_center; justify_center; h full; w full ]
        [ of_htmlit icon ];
    ]

let mk_svg paths =
  svg ~at:[ At.view_box "0 0 20 20"; At.fill "currentColor"; Aria.hidden ] paths

let with_stroke ~width ~height ~stroke paths =
  svg
    ~at:
      [
        At.fill "none";
        At.view_box
          (Core.Pp.str
             [ "0 0 "; string_of_int width; " "; string_of_int height ]);
        Aria.hidden;
        At.stroke "currentColor";
        At.stroke_width stroke;
      ]
    paths

let _rocket =
  mk_svg
    [
      path
        ~at:
          [
            At.fill_rule `evenodd;
            At.d
              "M4.606 12.97a.75.75 0 01-.134 1.051 2.494 2.494 0 00-.93 2.437 \
               2.494 2.494 0 002.437-.93.75.75 0 111.186.918 3.995 3.995 0 \
               01-4.482 1.332.75.75 0 01-.461-.461 3.994 3.994 0 \
               011.332-4.482.75.75 0 011.052.134z";
            At.clip_rule `evenodd;
          ]
        [];
      path
        ~at:
          [
            At.fill_rule `evenodd;
            At.d
              "M5.752 12A13.07 13.07 0 008 14.248v4.002c0 .414.336.75.75.75a5 \
               5 0 004.797-6.414 12.984 12.984 0 005.45-10.848.75.75 0 \
               00-.735-.735 12.984 12.984 0 00-10.849 5.45A5 5 0 001 \
               11.25c.001.414.337.75.751.75h4.002zM13 9a2 2 0 100-4 2 2 0 000 \
               4z";
            At.clip_rule `evenodd;
          ]
        [];
    ]

let _people =
  mk_svg
    [
      path
        ~at:
          [
            At.d
              "M10 9a3 3 0 100-6 3 3 0 000 6zM6 8a2 2 0 11-4 0 2 2 0 014 \
               0zM1.49 15.326a.78.78 0 01-.358-.442 3 3 0 014.308-3.516 6.484 \
               6.484 0 00-1.905 3.959c-.023.222-.014.442.025.654a4.97 4.97 0 \
               01-2.07-.655zM16.44 15.98a4.97 4.97 0 002.07-.654.78.78 0 \
               00.357-.442 3 3 0 00-4.308-3.517 6.484 6.484 0 011.907 3.96 \
               2.32 2.32 0 01-.026.654zM18 8a2 2 0 11-4 0 2 2 0 014 0zM5.304 \
               16.19a.844.844 0 01-.277-.71 5 5 0 019.947 0 .843.843 0 \
               01-.277.71A6.975 6.975 0 0110 18a6.974 6.974 0 01-4.696-1.81z";
          ]
        [];
    ]

let _hat =
  mk_svg
    [
      path
        ~at:
          [
            At.fill_rule `evenodd;
            At.d
              "M9.664 1.319a.75.75 0 01.672 0 41.059 41.059 0 018.198 \
               5.424.75.75 0 01-.254 1.285 31.372 31.372 0 00-7.86 3.83.75.75 \
               0 01-.84 0 31.508 31.508 0 \
               00-2.08-1.287V9.394c0-.244.116-.463.302-.592a35.504 35.504 0 \
               013.305-2.033.75.75 0 00-.714-1.319 37 37 0 00-3.446 2.12A2.216 \
               2.216 0 006 9.393v.38a31.293 31.293 0 00-4.28-1.746.75.75 0 \
               01-.254-1.285 41.059 41.059 0 018.198-5.424zM6 11.459a29.848 \
               29.848 0 00-2.455-1.158 41.029 41.029 0 00-.39 3.114.75.75 0 \
               00.419.74c.528.256 1.046.53 \
               1.554.82-.21.324-.455.63-.739.914a.75.75 0 101.06 \
               1.06c.37-.369.69-.77.96-1.193a26.61 26.61 0 013.095 2.348.75.75 \
               0 00.992 0 26.547 26.547 0 015.93-3.95.75.75 0 00.42-.739 \
               41.053 41.053 0 00-.39-3.114 29.925 29.925 0 00-5.199 2.801 \
               2.25 2.25 0 01-2.514 0c-.41-.275-.826-.541-1.25-.797a6.985 \
               6.985 0 01-1.084 3.45 26.503 26.503 0 00-1.281-.78A5.487 5.487 \
               0 006 12v-.54z";
            At.clip_rule `evenodd;
          ]
        [];
    ]

let _stars =
  mk_svg
    [
      path
        ~at:
          [
            At.d
              "M15.98 1.804a1 1 0 00-1.96 0l-.24 1.192a1 1 0 \
               01-.784.785l-1.192.238a1 1 0 000 1.962l1.192.238a1 1 0 \
               01.785.785l.238 1.192a1 1 0 001.962 0l.238-1.192a1 1 0 \
               01.785-.785l1.192-.238a1 1 0 000-1.962l-1.192-.238a1 1 0 \
               01-.785-.785l-.238-1.192zM6.949 5.684a1 1 0 00-1.898 0l-.683 \
               2.051a1 1 0 01-.633.633l-2.051.683a1 1 0 000 1.898l2.051.684a1 \
               1 0 01.633.632l.683 2.051a1 1 0 001.898 0l.683-2.051a1 1 0 \
               01.633-.633l2.051-.683a1 1 0 000-1.898l-2.051-.683a1 1 0 \
               01-.633-.633L6.95 5.684zM13.949 13.684a1 1 0 00-1.898 \
               0l-.184.551a1 1 0 01-.632.633l-.551.183a1 1 0 000 \
               1.898l.551.183a1 1 0 01.633.633l.183.551a1 1 0 001.898 \
               0l.184-.551a1 1 0 01.632-.633l.551-.183a1 1 0 \
               000-1.898l-.551-.184a1 1 0 01-.633-.632l-.183-.551z";
          ]
        [];
    ]

let _sun =
  mk_svg
    [
      path
        ~at:
          [
            At.d
              "M10 2a.75.75 0 01.75.75v1.5a.75.75 0 01-1.5 0v-1.5A.75.75 0 \
               0110 2zM10 15a.75.75 0 01.75.75v1.5a.75.75 0 01-1.5 \
               0v-1.5A.75.75 0 0110 15zM10 7a3 3 0 100 6 3 3 0 000-6zM15.657 \
               5.404a.75.75 0 10-1.06-1.06l-1.061 1.06a.75.75 0 001.06 \
               1.06l1.06-1.06zM6.464 14.596a.75.75 0 10-1.06-1.06l-1.06 \
               1.06a.75.75 0 001.06 1.06l1.06-1.06zM18 10a.75.75 0 \
               01-.75.75h-1.5a.75.75 0 010-1.5h1.5A.75.75 0 0118 10zM5 \
               10a.75.75 0 01-.75.75h-1.5a.75.75 0 010-1.5h1.5A.75.75 0 015 \
               10zM14.596 15.657a.75.75 0 001.06-1.06l-1.06-1.061a.75.75 0 \
               10-1.06 1.06l1.06 1.06zM5.404 6.464a.75.75 0 \
               001.06-1.06l-1.06-1.06a.75.75 0 10-1.061 1.06l1.06 1.06z";
          ]
        [];
    ]

let _training =
  with_stroke ~width:42 ~height:42 ~stroke:"0.1"
    [
      g
        ~at:
          [
            At.fill "currentColor"; At.fill_rule `evenodd; At.clip_rule `evenodd;
          ]
        [
          path
            ~at:
              [
                At.d
                  "M6 6v28h22.387v-2H8V8h27v2.12h2V6zm31 10a2 2 0 1 1-4 0a2 2 \
                   0 0 1 4 0m2 0a4 4 0 1 1-8 0a4 4 0 0 1 8 0";
              ]
            [];
          path
            ~at:
              [
                At.d
                  "M30.093 21.83a3 3 0 0 1 2.07-.83h4.082c1.464 0 2.827.498 \
                   3.877 1.49c1.01.954 1.536 2.177 1.751 3.336c.338 1.822-.012 \
                   3.813-.873 5.578V39.5a2.5 2.5 0 0 \
                   1-4.966.411l-.534-3.204l-.534 3.204A2.5 2.5 0 0 1 30 \
                   39.5v-9.407a3 3 0 0 1-1.5.402h-5.102a3 3 0 0 1 0-6h3.9zM32 \
                   33.475V39.5a.5.5 0 0 0 .993.082l1.043-6.256a1 1 0 0 1 \
                   .986-.836h.956a1 1 0 0 1 .986.836l1.043 6.256A.5.5 0 0 0 39 \
                   39.5v-8.333a1 1 0 0 1 .112-.46c.772-1.491 \
                   1.053-3.124.795-4.516c-.157-.846-.524-1.648-1.158-2.247c-.647-.611-1.505-.944-2.504-.944h-4.081c-.257 \
                   0-.505.099-.691.276l-3.084 2.942a1 1 0 0 1-.69.277h-4.301a1 \
                   1 0 0 0 0 2H28.5a1 1 0 0 0 .69-.277l1.12-1.068a1 1 0 0 1 \
                   1.69.724z";
              ]
            [];
        ];
    ]

let _team_extension =
  with_stroke ~width:24 ~height:24 ~stroke:"1"
    [
      path
        ~at:
          [
            At.stroke_linecap "round";
            At.stroke_linejoin "round";
            At.d
              "M15 19.128a9.38 9.38 0 002.625.372 9.337 9.337 0 004.121-.952 \
               4.125 4.125 0 00-7.533-2.493M15 \
               19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 \
               12.318 0 018.624 21c-2.331 \
               0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 \
               0111.964-3.07M12 6.375a3.375 3.375 0 11-6.75 0 3.375 3.375 0 \
               016.75 0zm8.25 2.25a2.625 2.625 0 11-5.25 0 2.625 2.625 0 \
               015.25 0z";
          ]
        [];
    ]

let _consulting =
  with_stroke ~width:14 ~height:14 ~stroke:"0.7"
    [
      path
        ~at:
          [
            At.fill "none";
            At.stroke "currentColor";
            At.stroke_linecap "round";
            At.stroke_linejoin "round";
            At.d
              "M4.194 8.094a1.86 1.86 0 1 0 0-3.719a1.86 1.86 0 0 0 0 \
               3.719M.523 13.479A3.68 3.68 0 0 1 1 11.704a3.711 3.711 0 0 1 \
               3.195-1.868c1.31.003 2.55.727 3.195 1.868a3.68 3.68 0 0 1 .477 \
               1.774m2.02-12.095v-.82m2.799 \
               1.827l.671-.471m-6.271.471l-.672-.471m5.506 3.139a2.055 2.055 0 \
               0 0-2.077-2.042a2.055 2.055 0 0 0-1.99 2.127a2.067 2.067 0 0 0 \
               1.126 1.73v1a.227.227 0 0 0 .226.22h1.361a.227.227 0 0 0 \
               .227-.22V6.855a2.07 2.07 0 0 0 1.128-1.797Z";
          ]
        [];
    ]

let _tailor =
  with_stroke ~width:24 ~height:24 ~stroke:"1.5"
    [
      path
        ~at:
          [
            At.fill "none";
            At.stroke "currentColor";
            At.stroke_linecap "round";
            At.stroke_linejoin "round";
            At.d
              "M8.252 18.459C7.462 19.764 7.107 21 5.7 21C4.209 21 3 19.757 3 \
               18.223s1.209-2.778 2.7-2.778c1.4 0 2.55 1.095 2.686 \
               2.498a.846.846 0 0 1-.134.515m0 0l1.948-3.476m5.548 \
               3.476C16.538 19.764 16.893 21 18.3 21c1.491 0 2.7-1.243 \
               2.7-2.777s-1.209-2.778-2.7-2.778c-1.4 0-2.55 1.095-2.687 \
               2.498c-.017.182.04.36.135.515m0 0L7.093 3.346a.659.659 0 0 \
               0-1.1-.081c-1.704 2.19-1.534 5.35.395 \
               7.333zm-3.797-6.63l4.953-8.494a.66.66 0 0 1 1.098-.076c1.707 \
               2.194 1.537 5.358-.395 7.345L16.5 11.742";
          ]
        [];
    ]

let _feature =
  with_stroke ~width:32 ~height:32 ~stroke:"0.01"
    [
      path
        ~at:
          [
            At.fill "currentColor";
            At.d
              "M8 4v4H4V4zM2 2v8h8V2zm16 5v4h-4V7zm-6-2v8h8V5zM8 \
               16v4H4v-4zm-6-2v8h8v-8z";
          ]
        [];
      path
        ~at:
          [
            At.fill "currentColor";
            At.d
              "M22 10v6h-6v6h-6v8h20V10Zm-4 8h4v4h-4Zm-2 10h-4v-4h4Zm6 \
               0h-4v-4h4Zm6 0h-4v-4h4Zm0-6h-4v-4h4Zm-4-6v-4h4v4Z";
          ]
        [];
    ]

let _internal =
  with_stroke ~width:24 ~height:24 ~stroke:"0.1"
    [
      g
        ~at:[ At.fill "currentColor" ]
        [
          path
            ~at:
              [
                At.d "m20.708 4.412l-10.25 10.287h3.59v2h-7v-7h2v3.58L19.293 3z";
              ]
            [];
          path ~at:[ At.d "M11 4.706v2H5v12h12v-6h2v8H3v-16z" ] [];
        ];
    ]

let _tick =
  svg
    ~at:[ At.view_box "0 0 20 20"; At.fill "currentColor"; Html.Aria.hidden ]
    [
      path
        ~at:
          [
            At.fill_rule `evenodd;
            At.clip_rule `evenodd;
            At.d
              "M10 18a8 8 0 100-16 8 8 0 000 16zm3.857-9.809a.75.75 0 \
               00-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 10-1.06 1.061l2.5 \
               2.5a.75.75 0 001.137-.089l4-5.5z";
          ]
        [];
    ]

let _dot =
  svg
    ~at:[ At.view_box "0 0 4 4"; Html.Aria.hidden ]
    [ circle ~at:[ At.cx 2; At.cy 2; At.r 2; At.fill "currentColor" ] [] ]

let _back =
  svg
    ~at:[ At.view_box "0 0 20 20"; At.fill "currentColor"; Html.Aria.hidden ]
    [
      path
        ~at:
          [
            At.fill_rule `evenodd;
            At.clip_rule `evenodd;
            At.d
              "M12.79 5.23a.75.75 0 01-.02 1.06L8.832 10l3.938 3.71a.75.75 0 \
               11-1.04 1.08l-4.5-4.25a.75.75 0 010-1.08l4.5-4.25a.75.75 0 \
               011.06.02z";
          ]
        [];
    ]

let rss =
  of_htmlit
    (svg
       ~at:[ At.fill "currentColor"; At.view_box "0 0 24 24"; Html.Aria.hidden ]
       [
         path
           ~at:
             [
               At.d
                 "M0 0v24h24v-24h-24zm6.168 20c-1.197 \
                  0-2.168-.969-2.168-2.165s.971-2.165 2.168-2.165 2.167.969 \
                  2.167 2.165-.97 2.165-2.167 2.165zm5.18 \
                  0c-.041-4.029-3.314-7.298-7.348-7.339v-3.207c5.814.041 \
                  10.518 4.739 10.56 10.546h-3.212zm5.441 \
                  0c-.021-7.063-5.736-12.761-12.789-12.792v-3.208c8.83.031 \
                  15.98 7.179 16 16h-3.211z";
             ]
           [];
       ])

let github =
  of_htmlit
    (svg
       ~at:[ At.fill "currentColor"; At.view_box "0 0 24 24"; Html.Aria.hidden ]
       [
         path
           ~at:
             [
               At.fill_rule `evenodd;
               At.clip_rule `evenodd;
               At.d
                 "M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 \
                  9.504.5.092.682-.217.682-.483 \
                  0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 \
                  1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 \
                  2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 \
                  0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 \
                  0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 \
                  1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 \
                  1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 \
                  3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 \
                  1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 \
                  10.019 0 0022 12.017C22 6.484 17.522 2 12 2z";
             ]
           [];
       ])

let linkedin =
  of_htmlit
    (svg
       ~at:[ At.fill "currentColor"; At.view_box "0 0 24 24"; Html.Aria.hidden ]
       [
         path
           ~at:
             [
               At.d
                 "M20.447 \
                  20.452h-3.554v-5.569c0-1.327-.023-3.037-1.849-3.037-1.849 \
                  0-2.134 1.445-2.134 \
                  2.937v5.669H9.354V9h3.414v1.561h.049c.475-.9 1.637-1.849 \
                  3.369-1.849 3.602 0 4.271 2.37 4.271 5.458v6.281zM5.337 \
                  7.433c-1.144 0-2.07-.928-2.07-2.071s.926-2.071 \
                  2.07-2.071c1.145 0 2.071.928 2.071 2.071s-.926 2.071-2.071 \
                  2.071zm1.775 13.019H3.562V9h3.55v11.452zM22.225 0H1.771C.791 \
                  0 0 .774 0 1.729v20.542C0 23.226.791 24 1.771 \
                  24h20.451C23.205 24 24 23.226 24 22.271V1.729C24 .774 23.205 \
                  0 22.225 0z";
             ]
           [];
       ])

let bluesky =
  of_htmlit
    (svg
       ~at:
         [ At.fill "currentColor"; At.view_box "0 0 512 512"; Html.Aria.hidden ]
       [
         path
           ~at:
             [
               At.d
                 "M111.8 62.2C170.2 105.9 233 194.7 256 242.4c23-47.6 \
                  85.8-136.4 144.2-180.2c42.1-31.6 110.3-56 110.3 21.8c0 \
                  15.5-8.9 130.5-14.1 149.2C478.2 298 412 314.6 353.1 \
                  304.5c102.9 17.5 129.1 75.5 72.5 133.5c-107.4 \
                  110.2-154.3-27.6-166.3-62.9l0 \
                  0c-1.7-4.9-2.6-7.8-3.3-7.8s-1.6 3-3.3 7.8l0 0c-12 35.3-59 \
                  173.1-166.3 62.9c-56.5-58-30.4-116 72.5-133.5C100 314.6 33.8 \
                  298 15.7 233.1C10.4 214.4 1.5 99.4 1.5 83.9c0-77.8 68.2-53.4 \
                  110.3-21.8z";
             ]
           [];
       ])

let _ok =
  svg
    ~at:
      [
        At.fill "none";
        At.view_box "0 0 24 24";
        At.stroke_width "1.5";
        At.stroke "currentColor";
        Html.Aria.hidden;
      ]
    [
      path
        ~at:
          [
            At.stroke_linecap "round";
            At.stroke_linejoin "round";
            At.d "m4.5 12.75 6 6 9-13.5";
          ]
        [];
    ]

let _address =
  svg
    ~at:
      [
        At.fill "none";
        At.view_box "0 0 24 24";
        At.stroke_width "1.5";
        At.stroke "currentColor";
        Html.Aria.hidden;
      ]
    [
      path
        ~at:
          [
            At.stroke_linecap "round";
            At.stroke_linejoin "round";
            At.d
              "M2.25 21h19.5m-18-18v18m10.5-18v18m6-13.5V21M6.75 6.75h.75m-.75 \
               3h.75m-.75 3h.75m3-6h.75m-.75 3h.75m-.75 3h.75M6.75 \
               21v-3.375c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 \
               1.125 1.125V21M3 3h12m-.75 4.5H21m-3.75 \
               3.75h.008v.008h-.008v-.008Zm0 3h.008v.008h-.008v-.008Zm0 \
               3h.008v.008h-.008v-.008Z";
          ]
        [];
    ]

let _phone =
  svg
    ~at:
      [
        At.fill "none";
        At.view_box "0 0 24 24";
        At.stroke_width "1.5";
        At.stroke "currentColor";
        Html.Aria.hidden;
      ]
    [
      path
        ~at:
          [
            At.stroke_linecap "round";
            At.stroke_linejoin "round";
            At.d
              "M2.25 6.75c0 8.284 6.716 15 15 15h2.25a2.25 2.25 0 0 0 \
               2.25-2.25v-1.372c0-.516-.351-.966-.852-1.091l-4.423-1.106c-.44-.11-.902.055-1.173.417l-.97 \
               1.293c-.282.376-.769.542-1.21.38a12.035 12.035 0 0 \
               1-7.143-7.143c-.162-.441.004-.928.38-1.21l1.293-.97c.363-.271.527-.734.417-1.173L6.963 \
               3.102a1.125 1.125 0 0 0-1.091-.852H4.5A2.25 2.25 0 0 0 2.25 \
               4.5v2.25Z";
          ]
        [];
    ]

let _email =
  svg
    ~at:
      [
        At.fill "none";
        At.view_box "0 0 24 24";
        At.stroke_width "1.5";
        At.stroke "currentColor";
        Html.Aria.hidden;
      ]
    [
      path
        ~at:
          [
            At.stroke_linecap "round";
            At.stroke_linejoin "round";
            At.d
              "M21.75 6.75v10.5a2.25 2.25 0 0 1-2.25 2.25h-15a2.25 2.25 0 0 \
               1-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 \
               0 0 0-2.25 2.25m19.5 0v.243a2.25 2.25 0 0 1-1.07 1.916l-7.5 \
               4.615a2.25 2.25 0 0 1-2.36 0L3.32 8.91a2.25 2.25 0 0 \
               1-1.07-1.916V6.75";
          ]
        [];
    ]

let _calendar =
  svg
    ~at:[ At.view_box "0 0 20 20"; At.fill "currentColor"; Html.Aria.hidden ]
    [
      path
        ~at:
          [
            At.fill_rule `evenodd;
            At.clip_rule `evenodd;
            At.d
              "M5.75 2a.75.75 0 0 1 .75.75V4h7V2.75a.75.75 0 0 1 1.5 \
               0V4h.25A2.75 2.75 0 0 1 18 6.75v8.5A2.75 2.75 0 0 1 15.25 \
               18H4.75A2.75 2.75 0 0 1 2 15.25v-8.5A2.75 2.75 0 0 1 4.75 \
               4H5V2.75A.75.75 0 0 1 5.75 2Zm-1 5.5c-.69 0-1.25.56-1.25 \
               1.25v6.5c0 .69.56 1.25 1.25 1.25h10.5c.69 0 1.25-.56 \
               1.25-1.25v-6.5c0-.69-.56-1.25-1.25-1.25H4.75Z";
          ]
        [];
    ]

let _close =
  svg
    ~at:
      [
        At.fill "none";
        At.view_box "0 0 24 24";
        At.stroke_width "1.5";
        At.stroke "currentColor";
        Html.Aria.hidden;
      ]
    [
      path
        ~at:
          [
            At.stroke_linecap "round";
            At.stroke_linejoin "round";
            At.d "M6 18 18 6M6 6l12 12";
          ]
        [];
    ]

let _search =
  svg
    ~at:
      [
        At.v "width" "24"; At.v "height" "24"; At.fill "none"; Html.Aria.hidden;
      ]
    [
      path
        ~at:
          [
            At.d "m19 19-3.5-3.5";
            At.stroke "currentColor";
            At.stroke_width "2";
            At.stroke_linecap "round";
            At.stroke_linejoin "round";
          ]
        [];
      circle
        ~at:
          [
            At.cx 11;
            At.cy 11;
            At.r 6;
            At.stroke "currentColor";
            At.stroke_width "2";
            At.stroke_linecap "round";
            At.stroke_linejoin "round";
          ]
        [];
    ]

let _puzzle_piece =
  svg
    ~at:
      [
        At.fill "none";
        At.view_box "0 0 24 24";
        At.stroke_width "2";
        At.stroke "currentColor";
      ]
    [
      path
        ~at:
          [
            At.stroke_linecap "round";
            At.stroke_linejoin "round";
            At.d
              "M14.25 \
               6.087c0-.355.186-.676.401-.959.221-.29.349-.634.349-1.003 \
               0-1.036-1.007-1.875-2.25-1.875s-2.25.84-2.25 1.875c0 \
               .369.128.713.349 1.003.215.283.401.604.401.959v0a.64.64 0 0 \
               1-.657.643 48.39 48.39 0 0 1-4.163-.3c.186 1.613.293 3.25.315 \
               4.907a.656.656 0 0 1-.658.663v0c-.355 \
               0-.676-.186-.959-.401a1.647 1.647 0 0 0-1.003-.349c-1.036 \
               0-1.875 1.007-1.875 2.25s.84 2.25 1.875 2.25c.369 0 .713-.128 \
               1.003-.349.283-.215.604-.401.959-.401v0c.31 0 \
               .555.26.532.57a48.039 48.039 0 0 1-.642 5.056c1.518.19 \
               3.058.309 4.616.354a.64.64 0 0 0 \
               .657-.643v0c0-.355-.186-.676-.401-.959a1.647 1.647 0 0 \
               1-.349-1.003c0-1.035 1.008-1.875 2.25-1.875 1.243 0 2.25.84 \
               2.25 1.875 0 .369-.128.713-.349 \
               1.003-.215.283-.4.604-.4.959v0c0 .333.277.599.61.58a48.1 48.1 0 \
               0 0 5.427-.63 48.05 48.05 0 0 0 .582-4.717.532.532 0 0 \
               0-.533-.57v0c-.355 \
               0-.676.186-.959.401-.29.221-.634.349-1.003.349-1.035 \
               0-1.875-1.007-1.875-2.25s.84-2.25 1.875-2.25c.37 0 .713.128 \
               1.003.349.283.215.604.401.96.401v0a.656.656 0 0 0 .658-.663 \
               48.422 48.422 0 0 \
               0-.37-5.36c-1.886.342-3.81.574-5.766.689a.578.578 0 0 \
               1-.61-.58v0Z";
          ]
        [];
    ]

let _document_text =
  svg
    ~at:
      [
        At.fill "none";
        At.view_box "0 0 24 24";
        At.stroke_width "1.5";
        At.stroke "currentColor";
      ]
    [
      path
        ~at:
          [
            At.stroke_linecap "round";
            At.stroke_linejoin "round";
            At.d
              "M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 \
               1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 \
               0-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 \
               0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 \
               1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z";
          ]
        [];
    ]

let _down_arrow =
  svg
    ~at:[ At.view_box "0 0 16 16"; At.fill "currentColor"; Html.Aria.hidden ]
    [
      path
        ~at:
          [
            At.fill_rule `evenodd;
            At.clip_rule `evenodd;
            At.d
              "M4.22 6.22a.75.75 0 0 1 1.06 0L8 8.94l2.72-2.72a.75.75 0 1 1 \
               1.06 1.06l-3.25 3.25a.75.75 0 0 1-1.06 0L4.22 7.28a.75.75 0 0 1 \
               0-1.06Z";
          ]
        [];
    ]

(* Heroicons for companies and projects *)
let _docker_logo =
  (* Cube (container/packaging) icon from Heroicons *)
  svg
    ~at:
      [
        At.fill "none";
        At.view_box "0 0 24 24";
        At.stroke "currentColor";
        At.stroke_width "1.5";
        Html.Aria.hidden;
      ]
    [
      path
        ~at:
          [
            At.stroke_linecap "round";
            At.stroke_linejoin "round";
            At.d
              "M21 7.5V18M15 7.5V18M3 16.8V9.2c0-.56 0-.84.109-1.054a1 1 0 \
               01.437-.437C3.76 7.5 4.04 7.5 4.6 7.5h1.8c.56 0 .84 0 \
               1.054.109a1 1 0 01.437.437C8 8.26 8 8.54 8 9.1v7.8c0 .56 0 \
               .84-.109 1.054a1 1 0 01-.437.437C7.24 18.5 6.96 18.5 6.4 \
               18.5H4.6c-.56 0-.84 0-1.054-.109a1 1 0 01-.437-.437C3 17.74 3 \
               17.46 3 16.9z";
          ]
        [];
    ]

let _amazon_logo =
  (* Cloud icon from Heroicons *)
  svg
    ~at:
      [
        At.fill "none";
        At.view_box "0 0 24 24";
        At.stroke "currentColor";
        At.stroke_width "1.5";
        Html.Aria.hidden;
      ]
    [
      path
        ~at:
          [
            At.stroke_linecap "round";
            At.stroke_linejoin "round";
            At.d
              "M2.25 15a4.5 4.5 0 004.5 4.5H16.5A2.25 2.25 0 0018.75 17.25 \
               4.875 4.875 0 0016.5 8.25a4.5 4.5 0 00-4.5-4.5 3.75 3.75 0 \
               00-3.75 3.75A4.5 4.5 0 002.25 15z";
          ]
        [];
    ]

let _citrix_logo =
  (* Server icon from Heroicons *)
  svg
    ~at:
      [
        At.fill "none";
        At.view_box "0 0 24 24";
        At.stroke "currentColor";
        At.stroke_width "1.5";
        Html.Aria.hidden;
      ]
    [
      path
        ~at:
          [
            At.stroke_linecap "round";
            At.stroke_linejoin "round";
            At.d
              "M5.25 14.25h13.5m-13.5 0a3 3 0 01-3-3m3 3a3 3 0 100 6h13.5a3 3 \
               0 100-6m-16.5-3a3 3 0 013-3h13.5a3 3 0 013 3m-19.5 0a4.5 4.5 0 \
               01.9-2.7L5.737 5.1a3.375 3.375 0 012.7-1.35h7.126c1.062 0 \
               2.062.5 2.7 1.35l2.587 3.45a4.5 4.5 0 01.9 2.7m0 0a3 3 0 01-3 3";
          ]
        [];
    ]

let ocaml_logo =
  (* Code bracket icon from Heroicons *)
  svg
    ~at:
      [
        At.fill "none";
        At.view_box "0 0 24 24";
        At.stroke "currentColor";
        At.stroke_width "1.5";
        Html.Aria.hidden;
      ]
    [
      path
        ~at:
          [
            At.stroke_linecap "round";
            At.stroke_linejoin "round";
            At.d
              "M17.25 6.75L22.5 12l-5.25 5.25m-10.5 0L1.5 \
               12l5.25-5.25m7.5-3l-4.5 16.5";
          ]
        [];
    ]

let _mirage_logo =
  (* Triangle (unikernel/pyramid) icon from Heroicons *)
  svg
    ~at:
      [
        At.fill "none";
        At.view_box "0 0 24 24";
        At.stroke "currentColor";
        At.stroke_width "1.5";
        Html.Aria.hidden;
      ]
    [
      path
        ~at:
          [
            At.stroke_linecap "round";
            At.stroke_linejoin "round";
            At.d
              "M14.25 \
               6.087c0-.355.186-.676.401-.959.221-.29.349-.634.349-1.003 \
               0-1.036-1.007-1.875-2.25-1.875s-2.25.84-2.25 1.875c0 \
               .369.128.713.349 1.003.215.283.401.604.401.959v0a.64.64 0 \
               01-.657.643 48.39 48.39 0 01-4.163-.3c.186 1.613.293 3.25.315 \
               4.907a.656.656 0 01-.658.663v0c-.355 \
               0-.676-.186-.959-.401a1.647 1.647 0 00-1.003-.349c-1.036 \
               0-1.875 1.007-1.875 2.25s.84 2.25 1.875 2.25c.369 0 .713-.128 \
               1.003-.349.283-.215.604-.401.959-.401v0c.31 0 \
               .555.26.532.57a48.039 48.039 0 01-.642 5.056c1.518.19 3.058.309 \
               4.616.354a.64.64 0 \
               00.657-.643v0c0-.355-.186-.676-.401-.959a1.647 1.647 0 \
               01-.349-1.003c0-1.035 1.008-1.875 2.25-1.875 1.243 0 2.25.84 \
               2.25 1.875 0 .369-.128.713-.349 \
               1.003-.215.283-.4.604-.4.959v0c0 .333.277.599.61.58a48.1 48.1 0 \
               005.427-.63 48.05 48.05 0 00.582-4.717.532.532 0 \
               00-.533-.57v0c-.355 \
               0-.676.186-.959.401-.29.221-.634.349-1.003.349-1.035 \
               0-1.875-1.007-1.875-2.25s.84-2.25 1.875-2.25c.37 0 .713.128 \
               1.003.349.283.215.604.401.96.401v0a.656.656 0 00.658-.663 \
               48.422 48.422 0 \
               00-.37-5.36c-1.886.342-3.81.574-5.766.689a.578.578 0 \
               01-.61-.58v0z";
          ]
        [];
    ]

let _irmin_logo =
  (* Git branch (version control) icon from Heroicons *)
  svg
    ~at:
      [
        At.fill "none";
        At.view_box "0 0 24 24";
        At.stroke "currentColor";
        At.stroke_width "1.5";
        Html.Aria.hidden;
      ]
    [
      path
        ~at:
          [
            At.stroke_linecap "round";
            At.stroke_linejoin "round";
            At.d
              "M7.864 4.243A7.5 7.5 0 0119.5 10.5c0 2.92-.556 5.709-1.568 \
               8.268M5.742 6.364A7.465 7.465 0 004.5 10.5a7.464 7.464 0 \
               01-1.15 3.993m1.989 3.559A11.209 11.209 0 008.25 10.5a3.75 3.75 \
               0 117.5 0c0 .527-.021 1.049-.064 1.565M12 10.5a14.94 14.94 0 \
               01-3.6 9.75m6.633-4.596a18.666 18.666 0 01-2.485 5.33";
          ]
        [];
    ]

let _opam_logo =
  (* Archive box (package) icon from Heroicons *)
  svg
    ~at:
      [
        At.fill "none";
        At.view_box "0 0 24 24";
        At.stroke "currentColor";
        At.stroke_width "1.5";
        Html.Aria.hidden;
      ]
    [
      path
        ~at:
          [
            At.stroke_linecap "round";
            At.stroke_linejoin "round";
            At.d
              "m20.25 7.5-.625 10.632a2.25 2.25 0 01-2.247 2.118H6.622a2.25 \
               2.25 0 01-2.247-2.118L3.75 7.5M10 11.25h4M3.375 7.5h17.25c.621 \
               0 1.125-.504 \
               1.125-1.125v-1.5c0-.621-.504-1.125-1.125-1.125H3.375c-.621 \
               0-1.125.504-1.125 1.125v1.5c0 .621.504 1.125 1.125 1.125z";
          ]
        [];
    ]

let twitter =
  of_htmlit
    ((* Twitter/X icon from footer.ml *)
     svg
       ~at:[ At.fill "currentColor"; At.view_box "0 0 24 24"; Html.Aria.hidden ]
       [
         path
           ~at:
             [
               At.d
                 "M18.244 2.25h3.308l-7.227 8.26 8.502 \
                  11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 \
                  2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z";
             ]
           [];
       ])

let x = twitter (* Same icon for Twitter/X *)

let discord =
  of_htmlit
    ((* Discord icon from Heroicons *)
     svg
       ~at:
         [
           At.fill "none";
           At.view_box "0 0 24 24";
           At.stroke "currentColor";
           At.stroke_width "1.5";
           Html.Aria.hidden;
         ]
       [
         path
           ~at:
             [
               At.stroke_linecap "round";
               At.stroke_linejoin "round";
               At.d
                 "M8.625 12a.375.375 0 11-.75 0 .375.375 0 01.75 0zm0 \
                  0H8.25m4.125 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zm0 \
                  0H12m4.125 0a.375.375 0 11-.75 0 .375.375 0 01.75 0zm0 \
                  0h-.375M21 12a9 9 0 11-18 0 9 9 0 0118 0z";
             ]
           [];
       ])

let ocaml_org = of_htmlit ocaml_logo (* Use the existing OCaml logo *)

let external_link =
  of_htmlit
    ((* Arrow pointing out of a box - Heroicons style *)
     svg
       ~at:
         [
           At.fill "none";
           At.view_box "0 0 20 20";
           At.stroke "currentColor";
           At.stroke_width "1.5";
           Html.Aria.hidden;
         ]
       [
         path
           ~at:
             [
               At.stroke_linecap "round";
               At.stroke_linejoin "round";
               At.d
                 "M11 3h6m0 0v6m0-6l-7 7m4 1v5a1 1 0 01-1 1H4a1 1 0 01-1-1V8a1 \
                  1 0 011-1h5";
             ]
           [];
       ])
