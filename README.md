# www.ezpz.host

The public marketing and docs site for ezpz.host. Plain HTML and CSS —
no framework, no build step, no third-party requests (fonts, analytics,
CDNs). Served directly by GitHub Pages.

Every other repo in this org (`api`, `vps`, `billing`, `niles`) is a Go
microservice with its own Docker image and docker-compose entry. This
one is deliberately different: it's static content with nothing to
compile and nothing to deploy alongside the local dev stack, so it has
no Dockerfile and isn't wired into `devops/playground/`.

## Pages

Each page is a directory with an `index.html`, so URLs are clean
(`/policy/trust/`, not `/policy/trust.html`) and resolve identically
whether served by `python3 -m http.server` locally or GitHub Pages in
production — both serve `index.html` for a directory request, so there's
no templating or rewrite-rule layer that could behave differently in
the two places.

| Path                       | What                                          |
| --------------------------- | --------------------------------------------- |
| `/`                         | Home                                          |
| `/servers/`                 | Providers, regions, and sizes/pricing         |
| `/giants/`                  | Credits — SporeStack and other prior art      |
| `/doc/`                     | Doc landing page: two link sections (below)   |
| `/doc/start/`               | Getting-started walkthrough (token → fund → create) |
| `/doc/api/`                 | API reference entry point + authentication    |
| `/doc/vps/`                 | VPS lifecycle, states, endpoints              |
| `/doc/billing/`             | Days-per-size billing model, endpoints        |
| `/doc/token/`               | Token model, endpoints                        |
| `/policy/`                  | Index of the five policy pages below          |
| `/policy/trust/`            | Trust (stub — coming soon)                    |
| `/policy/privacy/`          | Privacy Policy (stub — coming soon)           |
| `/policy/acceptable-use/`   | Acceptable Use Policy (stub — coming soon)    |
| `/policy/retention/`        | Retention Policy (stub — coming soon)         |
| `/policy/disclosures/`      | Disclosures (stub — coming soon)              |

`/doc/` and `/policy/` are both landing pages, not content — `/doc/` has
a "Start here" section (linking to `/doc/start/`) and an "API docs"
section (linking to `/doc/api/`, `/doc/vps/`, `/doc/billing/`,
`/doc/token/`); `/policy/` links out to the five policy pages. There's
no footer on any page. The five policy pages are bare "being finalized"
stubs for now — that's deliberate; real legal text needs an actual
lawyer's review before launch, not an LLM-drafted policy passed off as
reviewed.

`support@ezpz.host` is referenced on `/doc/billing/` as the contact
address for wrong-size funding — **that inbox needs to actually exist
before this goes live.**

## No scanning, no indexing

`robots.txt` disallows every crawler (`User-agent: * / Disallow: /`),
plus explicit entries for known AI trainers/crawlers (GPTBot, ClaudeBot,
CCBot, Google-Extended, PerplexityBot, and others) in case a given bot
only honors an exact user-agent match rather than the wildcard. Every
page also carries `<meta name="robots" content="noindex, nofollow">`,
which is the stronger signal search engines actually recommend for
guaranteed exclusion — a `Disallow` alone only stops crawling, not
necessarily indexing a URL discovered via an external link.

## Development

No dependencies beyond Python 3 (for local preview only — GitHub Pages
serves the files directly, nothing about local dev is a build step).

```sh
make help    # list targets
make serve   # python3 -m http.server on :8000 — matches production exactly,
             # since there's no templating or build step to diverge from
make check   # starts a server, runs scripts/smoke_test.sh against every
             # page (asserts 200s + that unknown paths 404), tears down
```

## Deployment

`.github/workflows/deploy.yml` publishes to GitHub Pages on every push
to `main`, using GitHub's native Pages Actions (no third-party action).
This requires a one-time manual setting no workflow file can make:
**Settings → Pages → Source → GitHub Actions.**

`CNAME` points the deployed site at `www.ezpz.host` — harmless as a file
until DNS is actually pointed there; update or delete it if that domain
changes. `.nojekyll` disables GitHub's automatic Jekyll processing, so
Pages serves the exact same static files `make serve` does locally —
there's no templating layer that could render differently in the two
places.

## Layout

```
*/index.html      one directory per page (see table above)
404.html          GitHub Pages' special top-level custom error page
assets/style.css  the one stylesheet
assets/nav.js     the one nav bar, included via <script> on every page
scripts/          smoke_test.sh, shared by `make check` and CI
.github/workflows/  ci.yml (smoke test on push/PR), deploy.yml (Pages)
```

The nav bar lives in exactly one place: `assets/nav.js` is a single
`document.write(...)` call, and every page's `<header>` is just
`<script src="/assets/nav.js"></script>`. That's the one piece of
JavaScript on the site — same-origin only, no third-party request, no
build step or template layer needed to keep every page's nav in sync.
`document.write` renders synchronously during page parse, so there's no
flash of a missing nav the way a `fetch()`-based include would have.
With JavaScript disabled, the nav simply doesn't appear; there's no
`<noscript>` fallback for it yet.

Same-origin `<hr>` right after `<header>` in every page: a plain
horizontal divider between the nav and the page content, styled by
nothing but the browser's own default rendering.

## Design notes

`assets/style.css` is deliberately tiny — a handful of rules, not a
design system. The philosophy: the browser's own default rendering
(fonts, link colors, heading sizes, spacing) is already a reasonable,
tasteful "early web" look, so CSS is added only where defaults actively
break something:

- A `max-width` on `body` so lines don't stretch edge-to-edge on wide
  screens.
- `overflow-x: auto` on `pre` so a long curl command scrolls inside its
  own box instead of blowing out the whole page's width.
- Borders and padding on `table`/`th`/`td`, since browsers don't draw
  table borders by default and the sizes/endpoint tables need visible
  cell separation to read.
- `display: block` + `padding-left` on `pre code` so multi-line code
  blocks indent consistently. Plain `code { padding-left }` only shows
  up before the very first line: horizontal padding on an inline element
  that wraps across lines is only rendered before the first line box and
  after the last one, not before every wrapped line — forcing `display:
  block` makes the whole thing one box instead. This is scoped to `pre
  code` specifically so inline `<code>` snippets in running prose don't
  pick up the same left padding.

Everything else — font family, link colors, blockquote indentation, the
`<hr>` line — is exactly what the browser already does with no CSS at
all. No dark mode (one look, not two to maintain). Each page's `<head>`
also sets `<meta name="referrer" content="no-referrer">`, the one
privacy touch achievable at the HTML level given GitHub Pages doesn't
allow custom response headers.
