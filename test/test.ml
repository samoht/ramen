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
let key k = Fmt.strf "{{ %s }}" k

let (++) f g x = f (g x)
let (+++) f g x = f (g x x)

let value = Alcotest.testable Template.(pp_entry Fmt.string) (=)
let context = Alcotest.testable Template.Context.dump Template.Context.equal
let error = Alcotest.testable Template.pp_error (=)
let file = "test"

let ast =
  let equal x y =Template.Ast.(equal (normalize x) (normalize y)) in
  Alcotest.testable Template.Ast.dump equal

let parse fmt = Format.ksprintf Template.Ast.parse fmt

let html x = parse "<html><head></head><body>%s</body></html>" x

let simple_context ctx =
  Template.Context.v @@
  List.map (fun (k, v) -> Template.data k v) ctx

module One = struct

  let check template k v =
    let e = Template.data k v in
    let tmpl = Template.subst ~file e (template @@ key k) in
    Alcotest.(check @@ result ast error) k (Ok (template v)) tmpl

  let simple () =
    check html "foo1" "bar";
    check html "foo2" "<div>bar</div>";
    check (html ++ strf "<foo><br /><bar>%s</bar></foo>") "foo3" "bar"

  let head () =
    check (parse "<html>%s<body>foo</body></html>")
      "HEAD"
      {|<head><link rel="stylesheet" href="style.css" type="text/css"></head>|}

  let body () =
    check (parse "<html><head></head>%s</html>") "BODY" "<body>foo</body>"

  let all () =
    let check = check in
    check (html +++ strf "%s </br> %s") "foo1" "bar";
    check (html +++ strf "%s<div>%s</div>") "foo2" "bar";
    check (html +++ strf "<div>%s</div><div>%s</div>") "foo3" "bar"

end

module Many = struct

  let check input output ctx =
    let ctx = simple_context ctx in
    let res, errors = Template.eval ~file ctx input in
    Alcotest.(check @@ slist error compare) "errors" [] errors;
    Alcotest.(check ast) "output" output res

  let simple () =
    check (html "{{ foo }} {{ bar }}") (html "gna gna") [
      "foo", "{{ bar }}";
      "bar", "gna";
    ]

  let complex () =
    check (html "{{ fo }}o }}") (html "hello <div>world</div>") [
      "fo"  , "hell{{ x";
      "xo"  , "o {{ bar }}";
      "bar" , "<div>{{ toto }}</div>";
      "toto", "world";
    ]

end

module Page = struct

  let data x = Template.Ast.Data x

  let check str body ctx =
    let ctx = simple_context ctx in
    let page = Template.parse_page ~file:"test" str in
    Alcotest.(check ast) "body" page.Template.body body;
    Alcotest.(check context) "rules" page.Template.context ctx

  let body () =
    check "" (data "") [];
    check "---\n" (data "") [];
    check "---\nfoo" (data "foo") []

  let headers () =
    check "foo: bar\nbar: toto\n---\n" (data "")
      ["foo", "bar"; "bar", "toto"];
    check "---\nfoo: bar\n---\n" (data "")
      ["foo", "bar"]

  let both () =
    check {|
foo: bar
bar: toto
---
this is a trap!
|}
      (data "this is a trap!\n")
      ["foo" , "bar"; "bar" , "toto"]

end


let (/) = Filename.concat
let mkdir dir = assert (Fmt.kstrf Sys.command "mkdir -p %s" dir = 0)
let rmdir dir =
  if dir = "/"
  || dir = "."
  || List.mem ".git" (try Sys.readdir dir |> Array.to_list with _ -> [])
  then assert false
  else assert (Fmt.kstrf Sys.command "rm -rf %s" dir = 0)
let init test_dir files =
  rmdir test_dir;
  mkdir test_dir;
  List.iter (fun (k, v) ->
      mkdir (test_dir / Filename.dirname k);
      let oc = open_out (test_dir / k) in
      output_string oc v;
      close_out oc
    ) files

module Data = struct

  let read_file file =
    let ic = open_in file in
    let s = really_input_string ic (in_channel_length ic) in
    close_in ic;
    s

  let files = [
    "foo.x"    , "xcxcxxc";
    "bar.x"    , "dsasasaddasdas asdasdaasad asdas";
    "foo/bar.x", "test test test test";
    "toto.yml" , "foo: bar\nbar: toto\n";
  ]

  let read () =
    let test_dir = "_tests" in
    init test_dir files;
    let data = Template.read_data test_dir in
    let ctx = Template.(Context.v [
        data "bar" @@ List.assoc "bar.x" files;
        data "foo" @@ List.assoc "foo.x" files;
        collection "foo" [
          data "bar" "test test test test";
        ];
        collection "toto" [
          data "foo" "bar";
          data "bar" "toto";
        ]
      ]) in
    Alcotest.(check context) "data" data ctx

end

module For = struct

  let ctx =
    let open Template in
    Context.v [
      collection "toto" [
        collection "foo" [
          data "name" "Jean Valjean";
          data "age"  "99";
          data "id"   "1";
        ];
        collection "bar" [
          data "name" "Monique";
          data "age"  "42";
          data "id"   "2";
        ];
      ]]

  let simple () =
    let one name age = Fmt.strf "Hi my name is %s and I am %s\n" name age in
    let template =
      Fmt.strf "Test: {{ for i in toto | name }}%s{{ endfor }}"
        (one "{{ i.name }}" "{{ i.age }}")
      |> Template.Ast.parse
    in
    let body =
      Fmt.strf "Test: %s%s" (one "Jean Valjean" "99") (one "Monique" "42")
      |> Template.Ast.parse
    in
    let str, e = Template.eval ~file ctx template in
    Alcotest.(check @@ slist error compare) "errors" [] e;
    Fmt.pr "XXX %a\n%!" Template.Ast.dump str;
    Alcotest.(check ast) "body" body str

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
    ];
    "for", [
      "simple", `Quick, For.simple;
    ]
  ]
