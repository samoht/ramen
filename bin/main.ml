let src = Logs.Src.create "ramen"
module Log = (val Logs.src_log src: Logs.LOG)

open Cmdliner

let (/) = Filename.concat

let data =
  let doc =
    Arg.info ~docv:"DIR"
      ~doc:"The directory containing the data (templates, md files, ...)"
      ["data"]
  in
  Arg.(value & opt string "data" doc)

let pages =
  let doc =
    Arg.info ~docv:"DIR"
      ~doc:"The directory containing the page templates."
      ["pages"]
  in
  Arg.(value & opt string "pages" doc)

let output =
  let doc =
    Arg.info ~docv:"DIR"
      ~doc:"The directory containing the output pages."
      ["output"; "o"]
  in
  Arg.(value & opt string "site" doc)

let failfast =
  let doc =
    Arg.info ~docv:"DIR"
      ~doc:"Fail on the first error instead of trying to continue."
      ["failfast"; "e"]
  in
  Arg.(value & flag doc)

let setup_log style_renderer level =
  Fmt_tty.setup_std_outputs ?style_renderer ();
  Logs.set_level level;
  let pp_header ppf x =
    Fmt.pf ppf "%5d: %a " (Unix.getpid ()) Logs_fmt.pp_header x
  in
  Logs.set_reporter (Logs_fmt.reporter ~pp_header ())

let setup_log =
  Term.(const setup_log $ Fmt_cli.style_renderer () $ Logs_cli.level ())

let pp_html oc page =
  let out = page (* |> Soup.parse |> Soup.pretty_print *) in
  Fmt.pf (Format.formatter_of_out_channel oc) "%s" out

let pp_pages dir ppf x =
  let pages s =
    Fmt.pf ppf "%a pages have been generated in %a/.\n%!"
      Fmt.(styled `Bold string) s
      Fmt.(styled `Underline string) dir
  in
  let page s =
    Fmt.pf ppf "%a page has been generated in %a/.\n%!"
      Fmt.(styled `Bold string) s
      Fmt.(styled `Underline string) dir
  in
  match List.length x with
  | 0 -> pages "No"
  | 1 -> page  "1"
  | n -> pages (string_of_int n)

let string_of_time () =
  let t = Unix.localtime (Unix.time ()) in
  Printf.sprintf "%d/%d/%d"
    t.Unix.tm_mday (t.Unix.tm_mon + 1) (t.Unix.tm_year + 1900)

let date = string_of_time ()

let site ~pages ~page =
  let pages =
    List.map (fun (p, c) ->
        let k = Filename.remove_extension @@ Filename.basename p.Template.file in
        Template.kollection k c
      ) pages
  in
  Template.Context.v [
    Template.collection "site" [
      Template.data       "date"  date;
      Template.kollection "page"  page;
      Template.collection "pages" pages;
    ]
  ]

let basename page =
  (* FIXME: support subdirs *)
  Filename.basename page.Template.file

let with_url context page =
  let url = Template.data "url" (basename page) in
  Template.Context.add context url

let check dir =
  if not (Sys.file_exists dir) || not (Sys.is_directory dir) then (
    Log.err (fun l -> l "The directory %s/ does not exists." dir);
    exit 1
  )

let run () data pages output failfast =
  check data;
  check pages;
  let data  = Template.read_data data in
  let pages = Template.read_pages ~dir:pages in
  let pages =
    List.map (fun page ->
        page, with_url (Template.context_of_page page) page
      ) pages
  in
  Log.info (fun l -> l "data: %a" Template.Context.pp data);
  if not (Sys.file_exists output) then Unix.mkdir output 0o755;
  let nb_errors = ref 0 in
  List.iter (fun (page, ctx) ->
      let {Template.context; file; body; _} = page in
      let output = output / basename page in
      Log.info (fun l -> l "Creating %s." output);
      let site = site ~pages ~page:ctx in
      let context = Template.Context.(context ++ data ++ site) in
      let out, errors = Template.eval ~file ~context ~failfast body in
      let oc = open_out output in
      pp_html oc @@ Fmt.to_to_string Template.Ast.pp out;
      flush oc;
      close_out oc;
      match errors with
      | [] -> ()
      | _  ->
        List.iter (fun e ->
            incr nb_errors;
            Fmt.epr "%a %a\n%!"
              Fmt.(styled `Red string) "[error]" Template.pp_error e
          ) errors;
    ) pages;
  Fmt.pr "%a" (pp_pages output) pages;
  if !nb_errors > 0 then exit 1

let run =
  let man = [
    `S "BUGS";
    `P "Check bug reports at https://github.com/samoht/ramen/issues.";
    `S "AUTHOR";
    `P "Thomas Gazagnaire <thomas@gazagnaire.org>";
  ] in
  Cmd.v
    (Cmd.info ~man "ramen" ~version:"%%VERSION%%")
    Term.(const run $ setup_log $ data $ pages $ output $ failfast)

let () = exit (Cmd.eval run)
