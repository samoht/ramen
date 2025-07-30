type t = {
  hover : Tw.t list option;
  site : Core.Site.t;
  palette : Colors.palette;
}
(** Component data for social links *)

let github ~palette url = Link.external' ~palette [ Icon.github ] url
let twitter ~palette url = Link.external' ~palette [ Icon.twitter ] url
let linkedin ~palette url = Link.external' ~palette [ Icon.linkedin ] url

let rss ~class_ ~palette =
  Link.internal' ~class_ ~palette [ Icon.rss ] "/feed.xml"

let render t =
  let site = t.site in
  let palette = t.palette in
  let color_social = [ Colors.text_muted palette ] in
  let socials = [] in
  let socials = rss ~class_:color_social ~palette :: socials in
  let socials =
    match site.Core.Site.social with
    | None -> socials
    | Some s ->
        let socials =
          match s.github with
          | Some username ->
              github ~palette ("https://github.com/" ^ username) :: socials
          | None -> socials
        in
        let socials =
          match s.twitter with
          | Some handle ->
              let username =
                if String.length handle > 0 && handle.[0] = '@' then
                  String.sub handle 1 (String.length handle - 1)
                else handle
              in
              twitter ~palette ("https://twitter.com/" ^ username) :: socials
          | None -> socials
        in
        let socials =
          match s.linkedin with
          | Some username ->
              linkedin ~palette ("https://linkedin.com/in/" ^ username)
              :: socials
          | None -> socials
        in
        socials
  in
  List.rev socials

let pp t =
  Core.Pp.record
    [
      ("hover", Core.Pp.option (Core.Pp.list Tw.pp) t.hover);
      ("site", Core.Site.pp t.site);
      ("palette", Colors.pp_palette t.palette);
    ]
