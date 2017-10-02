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
  let out = page |> Soup.parse |> Soup.pretty_print in
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

let extra = [
  Template.rule ~k:"{{ date }}" ~v:(string_of_time ());
]

let run () data pages output =
  let data = Template.read_data data in
  let pages = Template.read_pages pages in
  if not (Sys.file_exists output) then Unix.mkdir output 0o755;
  let nb_errors = ref 0 in
  List.iter (fun (f, kvs, body) ->
      let f = output / f in
      Log.info (fun l -> l "Creating %s." f);
      let out, errors = Template.eval ~file:f (kvs @ data @ extra) body in
      let oc = open_out f in
      pp_html oc out;
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
  Term.(const run $ setup_log $ data $ pages $ output),
  Term.info ~man "ramen" ~version:"%%VERSION%%"

let () = match Term.eval run with
  | `Error _ -> exit 1
  | `Ok () |`Help |`Version -> exit 0
