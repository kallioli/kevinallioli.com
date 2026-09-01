# DNS records for kevinallioli.com

Nothing in this file has been created. The `kevinallioli.com` zone exists on
Cloudflare and is empty; this is the exact set of records and rules to add
once the Pages project is up.

Assumed Pages project name: `kevinallioli-com`, which gives the deployment
hostname `kevinallioli-com.pages.dev`. If the project is named differently,
substitute it everywhere below.

## 1. Apex

Add `kevinallioli.com` as a custom domain on the Pages project
(*Workers & Pages → kevinallioli-com → Custom domains → Set up a domain*).
Because the zone is on the same account, Cloudflare creates this record
itself and issues the certificate:

| Type  | Name               | Content                     | Proxy   | TTL  |
| ----- | ------------------ | --------------------------- | ------- | ---- |
| CNAME | `kevinallioli.com` | `kevinallioli-com.pages.dev` | Proxied | Auto |

CNAME at the apex works through CNAME flattening; that is a Cloudflare
feature, not a DNS one, and it only works while the record is proxied.

To create it by hand instead, add exactly the row above.

## 2. www

`www` needs to reach Cloudflare's edge for a redirect rule to fire, which
means a proxied record. Two ways, pick one.

**Option A, recommended.** Add `www.kevinallioli.com` as a second custom
domain on the same Pages project. Cloudflare creates:

| Type  | Name  | Content                      | Proxy   | TTL  |
| ----- | ----- | ---------------------------- | ------- | ---- |
| CNAME | `www` | `kevinallioli-com.pages.dev` | Proxied | Auto |

The redirect rule in section 3 then answers before Pages ever serves a byte,
so `www` never returns content, only a 301.

**Option B, no second custom domain.** A placeholder record that exists only
to be proxied:

| Type | Name  | Content | Proxy   | TTL  |
| ---- | ----- | ------- | ------- | ---- |
| AAAA | `www` | `100::` | Proxied | Auto |

`100::` is the IPv6 discard prefix. Nothing is ever routed to it: the
redirect rule answers at the edge. This avoids attaching a domain to the
Pages project that is only ever redirected away from, at the cost of a
record whose purpose is not obvious to a future reader.

## 3. Redirect rule: www to apex

`_redirects` cannot do this. Cloudflare matches the `source` field of a
`_redirects` line against the request path and never against the hostname,
so a cross-hostname redirect has to be a zone rule.

*Rules → Redirect Rules → Create rule*, single redirect:

- **Name**: `www to apex`
- **Expression** (edit as custom filter expression):

  ```
  (http.host eq "www.kevinallioli.com")
  ```

- **Then**: URL redirect, **Dynamic**
- **Expression** for the target URL:

  ```
  concat("https://kevinallioli.com", http.request.uri.path)
  ```

- **Status code**: 301
- **Preserve query string**: on

## 4. Mail, for a domain that sends none

`kevinallioli.com` is not a mail domain: the contact address on the site is
`kevin@stackops.ch`. Saying so explicitly in DNS is what stops the domain
from being used to forge mail. All three are DNS-only, never proxied.

| Type | Name               | Content                                            | Proxy    | TTL  |
| ---- | ------------------ | -------------------------------------------------- | -------- | ---- |
| MX   | `kevinallioli.com` | `.` with priority `0`                              | DNS only | Auto |
| TXT  | `kevinallioli.com` | `v=spf1 -all`                                      | DNS only | Auto |
| TXT  | `_dmarc`           | `v=DMARC1; p=reject; rua=mailto:kevin@stackops.ch` | DNS only | Auto |
| TXT  | `*._domainkey`     | `v=DKIM1; p=`                                      | DNS only | Auto |

The null MX is RFC 7505: it tells a sending server there is no mail service
here, immediately, rather than after a timeout. If the domain ever needs to
receive mail, all four rows have to go.

## 5. Certificate issuance, optional

CAA records restrict which authorities may issue for the domain. Cloudflare
manages certificates for proxied hostnames and adds its own CAA entries when
needed, so this is only worth setting explicitly if you want to lock issuance
down further. Leave it alone unless that is a deliberate decision.

## Verification, once the records exist

```bash
dig +short kevinallioli.com
dig +short www.kevinallioli.com
curl -sI https://www.kevinallioli.com/articles/ | grep -Ei '^(HTTP|location)'
curl -sI https://kevinallioli.com/ | grep -Ei '^(HTTP|content-security-policy|strict-transport)'
curl -s https://kevinallioli.com/index.xml | head -5
```

Expected: `www` answers `301` with `location: https://kevinallioli.com/articles/`,
the apex answers `200` with the CSP and HSTS headers from `_headers`, and the
feed is valid RSS.
