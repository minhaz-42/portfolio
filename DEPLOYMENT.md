# Deployment

Static site. No build step, no dependencies, no package manager. The files in this
repository are the files that get served.

## How it publishes

`.github/workflows/gh-pages.yml` runs on every push to `main` and publishes the
repository root to the `gh-pages` branch via `peaceiris/actions-gh-pages`.

Current live URL: <https://minhaz-42.github.io/Tanvir-Ahmed/>

Because that is a *project* site, it is served from the `/Tanvir-Ahmed/` sub-path.
Every link and asset reference in the HTML is therefore **relative**
(`assets/css/site.css`, `privacy/`, `../favicon.svg`), never root-absolute
(`/assets/...`). Keep it that way, or the site will 404 on the sub-path.

## Local preview

```sh
python3 -m http.server 8000
# then open http://localhost:8000/
```

Routes to check: `/`, `/resume/`, `/privacy/`, `/terms/`, `/assets/cv/Tanvir-Ahmed-CV.pdf`.

## File map

```
index.html                 the whole main page
resume/index.html          /resume  -- the web CV
privacy/index.html         /privacy
terms/index.html           /terms
cv/Tanvir-Ahmed-CV.tex     the LaTeX CV: the source of the downloadable PDF
build-cv.sh                compiles the .tex and installs the PDF
assets/css/site.css        all styling
assets/fonts/              self-hosted Inter + Newsreader (latin subset) + OFL.txt
assets/img/                the portrait and the OG card
assets/cv/                 generated CV PDF -- do not hand-edit
favicon.svg .ico apple-touch-icon.png
robots.txt sitemap.xml
```

## The CV: LaTeX is the source of the PDF

`cv/Tanvir-Ahmed-CV.tex` is the CV. Its layout follows the widely used
[Jake's Resume](https://github.com/jakegut/resume) template (MIT licence): one
column, small-caps ruled section heads, `tabularx` entry rows, and
`\pdfgentounicode=1` so the text copies out cleanly for an applicant tracking
system. To change the CV, edit the `.tex` and run:

```sh
./build-cv.sh
```

That runs `pdflatex` twice (the entry headers use `tabularx` and need a second
pass to settle their widths), then copies the result to
`assets/cv/Tanvir-Ahmed-CV.pdf`. It currently produces 2 pages with 14
hyperlinks. Never edit the PDF directly: the next build discards the change.

Needs a TeX distribution with `fontawesome5`. On a clean Mac:
`brew install --cask mactex-no-gui`.

**`resume/index.html` mirrors the same content for the web**, because a PDF is
poor on a phone and poor for a screen reader. It is a second file, so if you
change one, change the other in the same commit. The two are in step as of this
writing.

---

## NOT YET DONE: custom domain

**This site is not launch-ready until a custom domain is connected.** Nothing is
invented in the files: everything currently points at the real
`minhaz-42.github.io/Tanvir-Ahmed` URL. When you have chosen a domain, do all five
steps below, in order.

### 1. Add the DNS records at your registrar

For an apex domain (`example.com`), four `A` records:

```
185.199.108.153
185.199.109.153
185.199.110.153
185.199.111.153
```

(and optionally the matching `AAAA` records `2606:50c0:8000::153`,
`2606:50c0:8001::153`, `2606:50c0:8002::153`, `2606:50c0:8003::153`)

For a `www` or other subdomain, one `CNAME` record instead:

```
www  ->  minhaz-42.github.io
```

Verify the current values against
<https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site>
before relying on them; GitHub has changed these IPs before.

### 2. Add a `CNAME` file to this repository root

One line, the bare domain, no scheme and no trailing slash:

```
example.com
```

Commit it at the root. The workflow publishes the root, so it will be carried to
`gh-pages` automatically. Do not create this file until the DNS records exist,
or GitHub Pages will fail its domain check.

### 3. Turn on HTTPS

In the repository: Settings, Pages, then set the custom domain and tick
**Enforce HTTPS** once the certificate has been issued. That can take up to
24 hours after DNS propagates.

### 4. Update every place the old URL is hard-coded

Search and replace `https://minhaz-42.github.io/Tanvir-Ahmed/` with the new
origin in:

| File | What to change |
|---|---|
| `index.html` | `<link rel="canonical">`, `og:url`, `og:image` |
| `privacy/index.html` | `<link rel="canonical">`, `og:url` |
| `terms/index.html` | `<link rel="canonical">`, `og:url` |
| `resume/index.html` | `<link rel="canonical">`, `og:url`, `og:image`, and the website line in the contact list |
| `sitemap.xml` | all four `<loc>` values, and bump `<lastmod>` |
| `robots.txt` | the `Sitemap:` line |
| `assets/img/og-card.png` | the URL printed on the card is `minhaz-42.github.io/Tanvir-Ahmed`; regenerate or edit it if you want the card to match |

Then rebuild the PDF, because the CV prints its own website URL:

```sh
./build-cv.sh
```

To find them all:

```sh
grep -rn "minhaz-42.github.io" . --include="*.html" --include="*.xml" --include="*.txt"
```

Note that `og:image` must stay an **absolute** URL, so it has to be updated even
though every other reference in the HTML is relative.

### 5. Re-submit the sitemap

Google Search Console and Bing Webmaster Tools both treat a new domain as a new
property. Add it and submit `https://<new-domain>/sitemap.xml`.

---

## Things deliberately not in this site

Worth knowing before you add anything, because the privacy policy makes specific
promises that these would break:

- No analytics, no cookies, no browser storage.
- No third-party requests at all. Fonts are self-hosted precisely so that loading a
  page contacts no other server. No CDN, no Google Fonts, no icon font.
- No contact form. The previous version of this site had one that submitted nowhere.
- No build tooling to keep up to date.

If you add analytics or a working contact form, update `privacy/index.html` and its
`Last updated` date in the same commit.
