(** Site configuration types *)

type link = { href : string; text : string }
type footer = { copyright : string; links : link list }

type social = {
  twitter : string option;
  github : string option;
  linkedin : string option;
}

type analytics = { google : string option; piwik : string option }

type t = {
  name : string;
  url : string;
  title : string;
  tagline : string;
  description : string;
  author : string;
  author_email : string;
  social : social option;
  analytics : analytics option;
  footer : footer;
  posts_per_page : int option;
}

let pp_link link =
  Pp.record [ ("href", Pp.quote link.href); ("text", Pp.quote link.text) ]

let pp_footer footer =
  Pp.record
    [
      ("copyright", Pp.quote footer.copyright);
      ("links", Pp.list pp_link footer.links);
    ]

let pp_social social =
  Pp.record
    [
      ("twitter", Pp.option Pp.quote social.twitter);
      ("github", Pp.option Pp.quote social.github);
      ("linkedin", Pp.option Pp.quote social.linkedin);
    ]

let pp_analytics analytics =
  Pp.record
    [
      ("google", Pp.option Pp.quote analytics.google);
      ("piwik", Pp.option Pp.quote analytics.piwik);
    ]

let pp t =
  Pp.record
    [
      ("name", Pp.quote t.name);
      ("url", Pp.quote t.url);
      ("title", Pp.quote t.title);
      ("tagline", Pp.quote t.tagline);
      ("description", Pp.quote t.description);
      ("author", Pp.quote t.author);
      ("author_email", Pp.quote t.author_email);
      ("social", Pp.option pp_social t.social);
      ("analytics", Pp.option pp_analytics t.analytics);
      ("footer", pp_footer t.footer);
      ("posts_per_page", Pp.option Pp.int t.posts_per_page);
    ]
