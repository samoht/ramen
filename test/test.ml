let reporter ?(prefix="") () =
  let report src level ~over k msgf =
    let k _ = over (); k () in
    let ppf = match level with Logs.App -> Fmt.stdout | _ -> Fmt.stderr in
    let with_stamp h _tags k fmt =
      Fmt.kpf k ppf ("%s %a %a @[" ^^ fmt ^^ "@]@.")
        prefix
        Fmt.(styled `Magenta string) (Logs.Src.name src)
        Logs_fmt.pp_header (level, h)
    in
    msgf @@ fun ?header ?tags fmt ->
    with_stamp header tags k fmt
  in
  { Logs.report = report }

let () =
  Logs.set_level (Some Logs.Debug);
  Logs.set_reporter (reporter ());
  Printexc.record_backtrace true

(* TESTS *)

let strf = Fmt.strf
let html x = strf "<html><head></head><body>%s</body></html>" x
let (++) f g x = f (g x)
let (+++) f g x = f (g x x)

let pp_rule ppf r = Fmt.pf ppf "%s: %s" (Template.k r) (Template.v r)
let rule = Alcotest.testable pp_rule (=)

module One = struct

  let check ?all template k v =
    let rule = Template.rule ~k ~v in
    let tmpl = Template.replace ?all rule (template k) in
    Alcotest.(check string) k (template v) tmpl

  let simple () =
    check html "foo1" "bar";
    check html "foo2" "<div>bar</div>";
    check (html ++ strf "<foo><br /><bar>%s</bar></foo>") "foo3" "bar"

  let head () =
    check
      (strf "<html>%s<body>foo</body></html>") "HEAD"
      {|<head><link rel="stylesheet" href="style.css" type="text/css"></head>|}

  let body () =
    check (strf "<html><head></head>%s</html>") "BODY" "<body>foo</body>"

  let all () =
    let check = check ~all:true in
    check (html +++ strf "%s </br> %s") "foo1" "bar";
    check (html +++ strf "%s<div>%s</div>") "foo2" "bar";
    check (html +++ strf "<div>%s</div><div>%s</div>") "foo3" "bar"

end

module Many = struct

  let check input output rules =
    let rules = List.map (fun (k, v) -> Template.rule ~k ~v) rules in
    Alcotest.(check string) input output (Template.eval rules input)

  let simple () =
    check (html "foo bar") (html "gna gna") [
      "foo", "bar";
      "bar", "gna";
    ]

  let complex () =
    check (html "foo") (html "hello <div>world</div>") [
      "fo"  , "hellx";
      "xo"  , "o bar";
      "bar" , "<div>toto</div>";
      "toto", "world";
    ]

end

module Page = struct

  let check str exp_body exp_rules =
    let exp_rules = List.map (fun (k, v) -> Template.rule ~k ~v) exp_rules in
    let rules, body = Template.parse_page str in
    Alcotest.(check string) "body" body exp_body;
    Alcotest.(check @@ slist rule compare) "rules" rules exp_rules

  let body () =
    check "" "" [];
    check "---\n" "" [];
    check "---\nfoo" "foo" []

  let headers () =
    check "foo: bar\nbar: toto\n---\n" ""
      ["{{ foo }}", "bar"; "{{ bar }}", "toto"];
    check "---\nfoo: bar\n---\n" ""
      ["{{ foo }}", "bar"]

  let both () =
    check {|
foo: bar
bar: toto
---
this is a trap!
|}
      "this is a trap!\n"
      [ "{{ foo }}", "bar";
        "{{ bar }}", "toto"]

end

module Data = struct

  let check msg rules exp_rules =
    let exp_rules = List.map (fun (k, v) -> Template.rule ~k ~v) exp_rules in
    Alcotest.(check @@ slist rule compare) msg rules exp_rules

  let read_file file =
    let ic = open_in file in
    let s = really_input_string ic (in_channel_length ic) in
    close_in ic;
    s

  let (/) = Filename.concat

  let read () =
    let dir =  "../../../test/data" in
    let data = Template.read_data dir in
    let bar_x = read_file (dir / "bar.x") in
    let foo_x = read_file (dir / "foo.x") in
    check "data" data [
      "{% include bar.x %}", bar_x;
      "{% include foo.x %}", foo_x;
    ]

end


let () =
  Alcotest.run "www" [
    "one", [
      "simple", `Quick, One.simple;
      "head"  , `Quick, One.head;
      "body"  , `Quick, One.body;
      "all"   , `Quick, One.all;
    ];
    "many", [
      "simple" , `Quick, Many.simple;
      "complex", `Quick, Many.complex;
    ];
    "page", [
      "body"   , `Quick, Page.body;
      "headers", `Quick, Page.headers;
      "both"   , `Quick, Page.both;
    ];
    "data", [
      "read", `Quick, Data.read;
    ]
  ]
