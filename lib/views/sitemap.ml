let pp_item ~site ppf (t : Core.Page.t) =
  let url = Core.Page.url t in
  Fmt.pf ppf
    {|
<url>
<loc>%s%s</loc>
<changefreq>daily</changefreq>
<priority>0.7</priority>
</url>|}
    site.Core.Site.url url

let generate ~site items =
  Fmt.str
    {|<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:news="http://www.google.com/schemas/sitemap-news/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:image="http://www.google.com/schemas/sitemap-image/1.1" xmlns:video="http://www.google.com/schemas/sitemap-video/1.1">%a</urlset>|}
    Fmt.(list ~sep:(any "") (pp_item ~site))
    items

let render ~site ~pages =
  let items =
    List.filter
      (function
        | Core.Page.Sitemap | Robots_txt | Blog_feed -> false | _ -> true)
      pages
  in
  let raw = generate ~site items in
  Ui.Layout.raw raw

let file = __FILE__
