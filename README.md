# kevinallioli.com

Personal site of Kevin Allioli: articles, projects, and the register of
upstream OpenStack contributions. Static, hand-written Hugo templates, no
third-party theme, no runtime dependency on anything outside this origin.

## What

- **Hugo extended**, version pinned in `.hugo-version` and checksum-pinned in
  `.hugo-sha256`. The same version is installed locally and in CI.
- **No theme, no Node, no bundler.** Every layout lives in `layouts/`. Hugo
  Pipes transpiles the SCSS, minifies it, and fingerprints it.
- **Self-hosted fonts.** IBM Plex (SIL OFL 1.1), subset to extended Latin,
  six `woff2` faces totalling 132 KB under `assets/fonts/`.
- **One inline script**, the theme toggle. Its SHA-256 is generated into the
  `script-src` directive of `_headers`, so the policy cannot drift from the
  script. `scripts/check-csp-hash.sh` proves it on every build.
- **Bilingual.** French is the default and lives at the root; English lives
  under `/en/`. Content directories are `content/fr/` and `content/en/`.

```
content/fr/           French content, served at /
content/en/           English content, served at /en/
data/contributions.yaml   the upstream register, rendered by a layout
assets/scss/          design tokens and stylesheets
assets/fonts/         subset IBM Plex woff2
assets/js/theme.js    the only script on the site
layouts/              hand-written templates, including _headers and _redirects
scripts/              build-time verification
```

`data/contributions.yaml` is the single source for the contributions page.
Add a change there and the page updates; the layout never needs touching.

## Run

Requires Hugo **extended**, the version in `.hugo-version`. Install it into
`~/.local/bin` (no root, no package manager):

```bash
version=$(cat .hugo-version)
curl -fsSLO "https://github.com/gohugoio/hugo/releases/download/v${version}/hugo_extended_${version}_linux-amd64.tar.gz"
sha256sum --check .hugo-sha256
tar -xzf "hugo_extended_${version}_linux-amd64.tar.gz" hugo
install -m755 hugo ~/.local/bin/hugo
```

Then:

```bash
make dev      # http://localhost:1313, drafts and future-dated posts included
```

`make dev` passes `--buildDrafts --buildFuture` on purpose: the eight article
outlines are drafts, and several are dated on their planned publication day.
A production build shows neither.

## Test

```bash
make build    # hugo --minify --gc, must finish with no warning
make check    # build, then verify the CSP hash against the served HTML
```

CI runs the same commands with `--panicOnWarning`, so a deprecation warning
fails the build rather than accumulating. It also runs `gitleaks` over the
full history.

Not covered by any automated check, and worth doing by hand before a
release: Lighthouse (performance and accessibility), keyboard navigation,
and both themes at 320 px width.

## Deploy

The site is published to **Cloudflare Workers Static Assets** by
`.github/workflows/ci.yml` on every push to `main`, with `wrangler deploy`
and a scoped API token. There is no Worker script: `wrangler.toml` declares
an assets directory and nothing else, so requests are served straight from
the asset server.

That is a deliberate constraint, not an omission. `_headers` is applied by
the asset server but **not** to responses produced by Worker code, and
`assets.run_worker_first` sends every request through the script. Putting a
Worker in front to handle the `www` redirect would silently drop the whole
security header set, generated CSP included. The `www` redirect is a zone
rule instead, which runs before Workers regardless.

Deployment is **gated**. The `deploy` job only runs when the repository
variable `DEPLOY_ENABLED` is set to `true`. Until then, a push to `main`
builds and verifies the site and stops there. Set it in
*Settings -> Secrets and variables -> Actions -> Variables* when the domain
is ready.

Required repository secrets:

| Name                    | Scope                                           |
| ----------------------- | ----------------------------------------------- |
| `CLOUDFLARE_API_TOKEN`  | See the four permissions in `docs/dns.md`       |
| `CLOUDFLARE_ACCOUNT_ID` | The account the Worker lives in                 |

The token needs *Account: Workers Scripts: Edit*, *Account: Account
Settings: Read*, and *Zone: Workers Routes: Edit* plus *Zone: Zone: Read*
scoped to `kevinallioli.com`. Notably **not** DNS Edit: custom domains are
created through the Workers Domains API, which writes the DNS record and
issues the certificate on Cloudflare's side.

No token is ever stored in this repository. `.env.example` documents the
non-secret variables only.

### DNS

The `kevinallioli.com` zone exists and is empty. Because the zone is on the
same account, the first `wrangler deploy` creates the two custom-domain
records and provisions their certificates. What stays manual is the
`www` to apex redirect rule and the mail-hardening records.
All of it is written out in `docs/dns.md`.

Cloudflare matches `_redirects` on the request path and never on the
hostname, which is why the `www` redirect cannot live in this repository.

## Architecture

`layouts/` follows Hugo's current template layout (`baseof.html`,
`home.html`, `page.html`, `section.html`, `_partials/`, `_shortcodes/`).
Section-specific templates are keyed on the page `type` rather than the
directory name, because the French and English section slugs differ
(`projets` and `projects`).

Two templates render plain text rather than HTML: `layouts/home.headers` and
`layouts/home.redirects` produce Cloudflare's `_headers` and `_redirects`
through custom output formats declared in `hugo.toml`. They are attached to
the French home page only, so exactly one of each is emitted.

Colour, type, and spacing are defined once as custom properties in
`assets/scss/_tokens.scss`. A theme is a token swap: nothing else in the
stylesheet knows which theme is active.

## Licence

Code (layouts, styles, scripts, workflows) under [MIT](LICENSE). Content
under [CC BY 4.0](LICENSE-CONTENT). IBM Plex under SIL OFL 1.1, see
`assets/fonts/LICENSE-OFL.txt`.
