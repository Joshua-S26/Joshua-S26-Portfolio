# Setup & Handoff: your click-by-click

The report is built and all the surrounding artifacts are written. This is the short list of things only you can do.
**Approach: high-res screenshots plus the written case study plus the browsable report code. No live embed, no Power BI Pro, $0.**

> Legend: 🟢 do now · 🟡 needs a download/account · ⚠️ watch out.

## 1 🟢 Confirm the numbers
Open the refreshed report and verify every figure I marked `[confirm]`. Search the repo for `[confirm]`
(it appears in `docs/index.html`, `case-study.md`, `data-dictionary.md`, `ATTRIBUTION.md`). Fix any that are off and
tell me, and I'll reconcile all the docs in one pass.

## 2 🟢 Capture the dashboard screenshot
1. In Power BI Desktop, open the **Executive Overview** page. View → Page view → **Fit to page**; maximize the window.
2. Take a high-res snip of the whole page (Win+Shift+S, or export per step 3).
3. Save it as **`docs/img/hero-dashboard.png`** (create the `docs/img/` folder). That's the only image the site needs,
   and the `<img>` slot is already wired to that path.

*(Optional, later: per-insight crops, such as a tight scatter and a scorecard crop, named `scatter.png` and
 `scorecard.png`. The page works with just the hero.)*

## 3 🟢 Export a PDF (nice-to-have download)
**File → Export → Export to PDF.** Save as `report/report.pdf` and commit it as a static version for non-technical viewers.

## 4 🟡 Commit the PBIP to the repo
Make sure `report/OlistDeliveryInsights.pbip` plus the `.SemanticModel/` (TMDL) and `.Report/` (PBIR) folders are
committed so a technical reviewer can read the model and DAX on GitHub. The `.gitignore` already drops the local caches
(`.pbi/`, `*.abf`) and the Kaggle CSVs.

## 5 🟡 Enable GitHub Pages
In **github.com/Joshua-S26/PBI-Portfolio → Settings → Pages**:
- **Source:** *Deploy from a branch* → **Branch: `main`**, **Folder: `/docs`** → **Save**.
- Wait about a minute. Your site goes live at **`https://joshua-s26.github.io/PBI-Portfolio/`**.

⚠️ If the page 404s, confirm the folder is `/docs` (not root) and that `docs/index.html` exists on `main`.

## 6 🟢 The site is wired
Your LinkedIn URL is already in `docs/index.html`. Everything else is set.

## 7 🟢 Ship the link
Put `https://joshua-s26.github.io/PBI-Portfolio/` on your resume header, LinkedIn Featured (slot 1), and outreach
templates. Bring the link back and I'll wire it into all three.

## Tier-2 (later, $0): Fabric proof
Start the free 60-day Fabric trial, create a Lakehouse, upload the CSVs to `Files/olist/`, run
`data-engineering/bronze_silver_gold.ipynb` end to end, screenshot the Lakehouse, notebook, and gold tables into
`data-engineering/screenshots/`, commit, then let the capacity expire. Don't let this block shipping.

## What's still on me
The doc realignment is done. When you send the confirmed numbers and the live link, I'll finalize copy,
sanity-check the recruiter five-second skim, and wire the URL into your resume, LinkedIn, and outreach.
