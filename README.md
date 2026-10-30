# juancamellini.github.io

Portfolio of **Juan Tomas Camellini**, data & operations analyst (logistics). Live at **https://juancamellini.github.io** (Spanish) and **https://juancamellini.github.io/en/** (English).

It shows:
- **Logistics experience:** the pick-up orders dashboard with daily automated data, SLA alerts and penalties for carriers, a Power App that generates pick-up orders, and a monthly KPI report.
- **Pick-up orders control:** SLA rules in Python, a daily alert per carrier, SQL KPIs on DuckDB and a Power BI dashboard, all on fictional data. Code: [logistics-control-tower](https://github.com/JuanCamellini/logistics-control-tower).
- **Electronic invoicing with ARCA:** in production since 31 Oct 2026. It issues about 100 invoices a month in minutes (over 16 hours by hand), with CAE, PDFs filed in Google Drive and duplicate protection, plus a 3-minute demo video on fictional data. The code is private.

## Structure

```
index.html                    Spanish home page
proyectos/                    Spanish project pages
en/                           English home page and en/projects/
assets/css/site.css           One stylesheet, light and dark (follows the system setting)
assets/fonts/                 Urbanist and JetBrains Mono, self-hosted (SIL Open Font License, see OFL-*.txt)
assets/img/, assets/video/    Screenshots and the invoicing demo (H.264 MP4)
assets/cv/                    Public CVs: no phone, email or address
tools/check_privacy.ps1       Pre-publish check for private data and pending items
```

Plain HTML and CSS: no framework, no build step, no JavaScript, no cookies, no tracking.

## Preview locally

Open `index.html` in a browser. To test the 404 page and absolute paths, serve the folder:

```bash
python -m http.server 8000
```

## Publish

1. Run the privacy check (it needs the local, gitignored `tools/private_patterns.txt`):
   ```powershell
   powershell -ExecutionPolicy Bypass -File tools\check_privacy.ps1
   ```
2. Push to `main`.
3. In **Settings → Pages**, choose **Deploy from a branch → main → / (root)**.

Every project shown here uses fictional data. Nothing comes from an employer's systems.
