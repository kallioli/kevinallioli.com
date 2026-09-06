# kevinallioli.com

Personal site of Kevin Allioli: articles, projects, and the register of
upstream OpenStack contributions. Static, hand-written Hugo templates, no
third-party theme, no runtime dependency on anything outside this origin.

## What

- **Hugo extended**, version pinned in `.hugo-version` and checksum-pinned in
  `.hugo-sha256`. The same version is installed locally and in CI.
- **No theme, no Node, no bundler.** Every layout lives in `layouts/`. Hugo
  Pipes transpiles the SCSS, minifies it, and fingerprints it.
- **Self-hosted fonts.** Spectral and IBM Plex Mono (both SIL OFL 1.1),
  subset to extended Latin, four `woff2` faces totalling 105 KB under
  `assets/fonts/`. There is no sans-serif on the site.
- **One inline script**, the theme toggle. Its SHA-256 is generated into the
  `script-src` directive of `_headers`, so the policy cannot drift from the
  script. `scripts/check-csp-hash.sh` proves it on every build.
- **Bilingual.** French is the default and lives at the root; English lives
  under `/en/`. Content directories are `content/fr/` and `content/en/`.

```
content/fr/           French content, served at /
content/en/           English content, served at /en/
data/contributions.yaml   the upstream register, generated, rendered by a layout
assets/scss/          design tokens and stylesheets
assets/fonts/         subset Spectral and IBM Plex Mono woff2
assets/js/theme.js    the only script on the site
layouts/              hand-written templates, including _headers and _redirects
scripts/              verification, the register generator, the Hugo pin
```

`data/contributions.yaml` is the single source for the contributions page,
and it is generated: run `scripts/fetch-contributions.sh` to rebuild it from
the public OpenDev Gerrit API, read the diff, commit it. The layout never
needs touching, and it fails the build if a Gerrit status it does not handle
would drop a row, because a register is only worth reading if it is complete.

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
make build    # production build; a warning is a failure
make check    # build, then verify the CSP hash against the served HTML
```

Both targets carry `--printPathWarnings --panicOnWarning`, the same flags CI
uses, so a deprecation warning or a missing layout fails the build rather
than accumulating. CI runs the identical commands and adds `gitleaks` over
the full history.

`scripts/smoke-test.sh [BASE_URL]` checks a deployed origin: that it answers,
that `_headers` is in force, that the CSP it serves carries the hash of the
script the local build produced, and that www still redirects to the apex.
The deploy job runs it against production.

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
non-secret variables only. The workflow's actions are pinned to commit SHAs
rather than to movable tags, since the deploy job holds that token.

## Dependencies

Renovate proposes the bumps, self-hosted in `.github/workflows/renovate.yml`
rather than through the Mend app: nothing outside this repository gets write
access to it. It runs weekly, writes with `RENOVATE_TOKEN`, and leaves the
workflow token read-only. It tracks the four pinned action digests, the
gitleaks release the secrets scan downloads, and the wrangler version the
deploy pins. Configuration is in `renovate.json`; the cron in the workflow is
the schedule, so the config carries none of its own.

Hugo is deliberately outside its reach. `.hugo-version` and `.hugo-sha256`
are one unit, and a bot can move the version but cannot compute the checksum
of the tarball it names. That is one command instead:

```bash
scripts/update-hugo.sh 0.166.0
```

It verifies the tarball against the checksums file published in the same
release before writing either file, and refuses to pin anything on a
mismatch.

### DNS

The `kevinallioli.com` zone is applied, mail hardening included. Because the
zone is on the same account, the first `wrangler deploy` creates the two
custom-domain records and provisions their certificates. What stays manual is
the `www` to apex redirect rule, which `scripts/smoke-test.sh` asserts on
every deploy. All of it is written out in `docs/dns.md`.

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
under [CC BY 4.0](LICENSE-CONTENT). Spectral and IBM Plex Mono under SIL
OFL 1.1, see the two `LICENSE-OFL-*.txt` files in `assets/fonts/`.
