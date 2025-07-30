let pp_item ~site ppf (b : Core.Blog.t) =
  let raw = Filename.basename b.slug in
  Fmt.pf ppf
    {|<item><title><![CDATA[%s]]></title><description><![CDATA[%s]]></description><link>%s/blog/%s</link><guid isPermaLink="false">%s/blog/%s.html</guid><dc:creator><![CDATA[ %s ]]></dc:creator><pubDate>%s 00:00:00 GMT</pubDate></item>|}
    b.title b.body_html site.Core.Site.url b.slug site.Core.Site.url raw
    (String.concat ", " (List.map Core.Blog.author_name b.authors))
    (Core.Blog.pretty_date b)
(* FIXME: the data and slug will be a bit different - does it matter? *)

let generate ~site items =
  let updated =
    match items with
    | [] -> "2024-01-01" (* Default date for empty feed *)
    | hd :: _ -> Core.Blog.pretty_date hd
  in
  (* FIXME: cutoff? *)
  Fmt.str
    {|<?xml version="1.0" encoding="UTF-8"?><rss xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:atom="http://www.w3.org/2005/Atom" version="2.0"><channel><title><![CDATA[%s RSS Feed]]></title><description><![CDATA[%s]]></description><link>%s</link><generator>Ramen</generator><lastBuildDate>%s 00:00:00 GMT</lastBuildDate>%a</channel></rss>|}
    site.Core.Site.name site.Core.Site.description site.Core.Site.url updated
    Fmt.(list ~sep:(any "") (pp_item ~site))
    items

let render ~site ~blog_posts =
  let raw = generate ~site blog_posts in
  Ui.Layout.raw raw

let file = __FILE__
