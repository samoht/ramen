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
  let equal x y =Template.Ast.(equal (normalize ~file x) (normalize ~file y)) in
  Alcotest.testable Template.Ast.dump equal

let parse fmt = Format.ksprintf Template.Ast.(parse ~file) fmt

let html x = parse "<html><head></head><body>%s</body></html>" x

let simple_context ctx =
  Template.Context.v @@
  List.map (fun (k, v) -> Template.data k v) ctx

module One = struct

  let check template k v =
    let e = Template.data k v in
    let context = Template.Context.v [e] in
    let tmpl, _ = Template.eval ~file ~context (template @@ key k) in
    Alcotest.(check ast) k (template v) tmpl

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
    let res, errors = Template.eval ~file ~context:ctx input in
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

  let text x = Template.Ast.Text x

  let check str body ctx =
    let ctx = simple_context ctx in
    let page = Template.parse_page ~file:"test" str in
    Alcotest.(check ast) "body" page.Template.body body;
    Alcotest.(check context) "rules" page.Template.context ctx

  let body () =
    check "" (text "") [];
    check "---\n" (text "") [];
    check "---\nfoo" (text "foo") []

  let headers () =
    check "foo: bar\nbar: toto\n---\n" (text "")
      ["foo", "bar"; "bar", "toto"];
    check "---\nfoo: bar\n---\n" (text "")
      ["foo", "bar"]

  let both () =
    check {|
foo: bar
bar: toto
---
this is a trap!
|}
      (text "this is a trap!\n")
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

  let test files ctx =
    let test_dir = "_tests" in
    init test_dir files;
    let data = Template.read_data test_dir in
    Alcotest.(check context) "data" ctx data

  let simple () =
    let files = [
      "bar.x"    , "dsasasaddasdas asdasdaasad asdas";
      "foo.x"    , "xcxcxxc";
      "fooo/bar.x", "test test test test";
      "toto.yml" , "foo: bar\nbar: toto\n";
      "zzzz/bar.x", "test test test test";
    ] in
    let file f x = Template.(collection f [data "body" x]) in
    let ctx = Template.(Context.v [
        file "bar" @@ List.assoc "bar.x" files;
        file "foo" @@ List.assoc "foo.x" files;
        collection "fooo" [
          file "bar" "test test test test";
        ];
        collection "toto" [
          data "foo" "bar";
          data "bar" "toto";
        ];
        collection "zzzz" [
          file "bar" "test test test test";
        ];
      ])
    in
    test files ctx

  let json () =
    let files = [
      "test.json"    ,
      {|{
        "foo": "bar",
        "toto": [41, 2, 13]
        }|};
    ] in
    let ctx = Template.(Context.v [
        collection "test" [
          data "foo" "bar";
          collection "toto" [
            data "0" "41";
            data "1" "2";
            data "2" "13"
          ]]]
      ) in
    test files ctx

end

module For = struct

  let ctx =
    let open Template in
    Context.v [
      collection "toto" [
        collection "bar" [
          data "name" "Monique";
          data "age"  "42";
          data "id"   "2";
        ];
        collection "foo" [
          data "name" "Jean Valjean";
          data "age"  "99";
          data "id"   "1";
        ];
      ]]

  let simple () =
    let one name age = Fmt.strf "Hi my name is %s and I am %s\n" name age in
    let template =
      Fmt.strf "Test: {{ for i in toto }}%s{{ endfor }}"
        (one "{{ i.name }}" "{{ i.age }}")
      |> Template.Ast.(parse ~file)
    in
    let body =
      Fmt.strf "Test: %s%s" (one "Monique" "42") (one "Jean Valjean" "99")
      |> Template.Ast.(parse ~file)
    in
    let str, e = Template.eval ~file ~context:ctx template in
    Alcotest.(check @@ slist error compare) "errors" [] e;
    Alcotest.(check ast) "body" body str

  let by_name () =
    let one name age = Fmt.strf "Hi my name is %s and I am %s\n" name age in
    let template =
      Fmt.strf "Test: {{ for i in toto | name }}%s{{ endfor }}"
        (one "{{ i.name }}" "{{ i.age }}")
      |> Template.Ast.(parse ~file)
    in
    let body =
      Fmt.strf "Test: %s%s" (one "Jean Valjean" "99") (one "Monique" "42")
      |> Template.Ast.(parse ~file)
    in
    let str, e = Template.eval ~file ~context:ctx template in
    Alcotest.(check @@ slist error compare) "errors" [] e;
    Alcotest.(check ast) "body" body str


  let f = Template.Ast.parse ~file

  let eval x =
    let x, y = Template.eval ~file:"test" ~context:ctx x in
    Alcotest.(check @@ slist error compare) "errors" [] y;
    x

  let test l =
    List.iteri (fun i (x, y) ->
        Alcotest.(check ast) (string_of_int i) (f y) (eval @@ f x)
      ) l

  let first () =
    test [
      "{{ for i in toto if (i = toto.first) i.name endif endfor }}",
      "Monique"
    ]

  let last () =
    test [
      "{{ for i in toto if (i = toto.last) i.name endif endfor }}",
      "Jean Valjean"
    ]

end

module If = struct

  let ctx =
    let open Template in
    Context.v [
      data "foo" "x";
      data "bar" "x";
      collection "toto" [
        data "name" "Jean Valjean";
      ]]

  let f = Template.Ast.parse ~file

  let eval x =
    let x, y = Template.eval ~file:"test" ~context:ctx x in
    Alcotest.(check @@ slist error compare) "errors" [] y;
    x

  let test l =
    List.iteri (fun i (x, y) ->
        Alcotest.(check ast) (string_of_int i) (f y) (eval @@ f x)
      ) l

  let simple () =
    test [
      "Hello {{ if toto.name }}world!{{ endif }}", "Hello world!";
      "Hi {{ if calvi }}Jean{{ endif }}"         , "Hi ";
    ]

  let many () =
    test [
      "{{if toto.name && foo}}hello!{{endif}}" , "hello!";
      "{{if calvi}}Jean{{elif foo}}yo{{endif}}", "yo";
    ]

  let equal () =
    test [
      "{{if (foo = bar)}}hello!{{endif}}"         , "hello!";
      "{{if (foo = bar) && toto.name}}yo{{endif}}", "yo";
    ]

  let neg () =
    test [
      "{{if !foo}}hello!{{endif}}"          , "";
      "{{if (foo != toto.name)}}yo{{endif}}", "yo";
    ]

  let else_ () =
    test [
      "{{if !foo}}hello!{{else}}By!{{endif}}", "By!";
      "{{if foo}}hello!{{else}}By!{{endif}}" , "hello!";
    ]
end

module Get = struct

  let ctx =
    let open Template in
    Context.v [
      collection "people" [
        collection "jean" [
          data "name" "Jean Valjean";
          data "age"  "99";
          data "id"   "1";
        ];
        collection "luc" [
          data "name" "Toto";
          data "age"  "42";
          data "id"   "2";
        ];
      ];
      collection "truc" [
        collection "one" [
          data "owner" "jean";
        ];
        collection "two" [
          data "owner" "luc";
        ]
      ]
    ]

  let f = Template.Ast.parse ~file

  let eval x =
    let x, y = Template.eval ~file:"test" ~context:ctx x in
    Alcotest.(check @@ slist error compare) "errors" [] y;
    x

  let simple () =
    List.iteri (fun i (x, y) ->
        Alcotest.(check ast) (string_of_int i) (f y) (eval @@ f x)
      )[
      "Hello {{ people.[truc.one.owner].name }}", "Hello Jean Valjean";
      "{{for i in truc}}{{people.[i.owner].name}} {{endfor}}",
      "Jean Valjean Toto ";
    ]

end

module Fun = struct

  let ctx =
    let open Template in
    Context.v [
      collection "truc" [
        collection "one" [
          data "owner" "jean";
        ];
        collection "two" [
          data "owner" "luc";
        ]
      ]
    ]

  let f = Template.Ast.parse ~file

  let eval x =
    let x, y = Template.eval ~file:"test" ~context:ctx x in
    Alcotest.(check @@ slist error compare) "errors" [] y;
    x

  let simple () =
    List.iteri (fun i (x, y) ->
        Alcotest.(check ast) (string_of_int i) (f y) (eval @@ f x)
      )[
      "Hello {{ truc(one: truc.two).one.owner }}", "Hello luc";
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
      "simple", `Quick, Data.simple;
      "json"  , `Quick, Data.json;
    ];
    "for", [
      "simple" , `Quick, For.simple;
      "by name", `Quick, For.by_name;
      "first"  , `Quick, For.first;
      "last"   , `Quick, For.last;
    ];
    "if", [
      "simple", `Quick, If.simple;
      "many"  , `Quick, If.many;
      "equal" , `Quick, If.equal;
      "neg"   , `Quick, If.neg;
      "else"  , `Quick, If.else_;
    ];
    "get", [
      "simple", `Quick, Get.simple;
    ];
    "functions", [
      "simple", `Quick, Fun.simple;
    ]
  ]
