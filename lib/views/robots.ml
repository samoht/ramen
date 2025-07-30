let render ~site =
  let raw =
    Fmt.str
      {|User-agent: *
Allow: /
Sitemap: https://%s/sitemap.xml
Host: https://%s
     |}
      site.Core.Site.url site.Core.Site.url
  in
  Ui.Layout.raw raw

let file = __FILE__
