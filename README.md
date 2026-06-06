# Olist Delivery Insights: Power BI portfolio project

**A single-page Power BI executive dashboard plus a written case study** on the Olist Brazilian e-commerce dataset
(about 100K orders). It answers a real marketplace question: late deliveries lower review scores and put repeat
revenue at risk, so where is it happening, why, and how much revenue is exposed?

> **Headline:** Late deliveries put about **$2.9M (roughly 21% of sales)** of repeat revenue at risk, and **on-time
> delivery is the fastest lever** to protect it. <!-- [confirm] figures -->

### ▶ Live case study: **https://joshua-s26.github.io/PBI-Portfolio/**

The report is authored as code in Power BI Desktop developer mode. The semantic model is in **TMDL** and the report is
in **PBIR (enhanced report format)**, so every table, DAX measure, and visual is a reviewable text file. The live site
presents high-resolution screenshots plus the written narrative; the full model and report code live in `/report`.

> Money figures are in Brazilian Reais (R$), the dataset's currency. The site shows them with a dollar sign for
> readability; they are not US dollars.

---

## What's here

| Path | What it is |
|---|---|
| `docs/` | The GitHub Pages case-study site (`index.html`, `styles.css`, `img/`) |
| `report/OlistDeliveryInsights.pbip` | The Power BI project, open in Desktop |
| `report/…SemanticModel/definition/` | **TMDL** model: tables, relationships, Power Query (M), full DAX library |
| `report/…Report/definition/` | **PBIR** report: the Executive Overview page, as JSON |
| `case-study.md` | The 5-minute written case study (problem, model, insights, impact) |
| `data-dictionary.md` | Every table, column, grain, and measure |
| `sql/` | DuckDB SQL that mirrors the model and recomputes every case-study number |
| `data-engineering/` | Tier-2: PySpark medallion (bronze, silver, gold) notebook plus Fabric architecture |
| `ATTRIBUTION.md` | Dataset license and credit (Olist, CC BY-NC) |

## The model at a glance

A star schema with **two fact tables at different grains** (the number-one modeling signal): order **lines** (revenue)
and order **headers** (delivery and satisfaction), sharing **conformed** Date and Customer dimensions. The headline
measure, **Revenue at Risk**, links the two grains virtually with `TREATAS`, so there is no ambiguous physical
relationship. See [`case-study.md`](case-study.md) and [`data-dictionary.md`](data-dictionary.md).

## Run it yourself

1. Download the 9 Olist CSVs from [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) into
   `report/data/` (not redistributed here; see [`ATTRIBUTION.md`](ATTRIBUTION.md)).
2. Open `report/OlistDeliveryInsights.pbip` in Power BI Desktop (preview features for PBIP, TMDL, and PBIR enabled),
   set the `CsvFolder` parameter to that folder, and refresh.
3. Optional: cross-check the numbers in DuckDB with `.read sql/01_dimensions.sql`, then `02_facts.sql`, then
   `03_compute_case_study_metrics.sql`.

## Tech

`Power BI` · `DAX` · `Power Query (M)` · `TMDL` · `PBIR` · `dimensional / star-schema modeling` ·
`Microsoft Fabric` · `PySpark` · `Delta Lake` · `SQL (DuckDB)`

---
**Joshua Short**, Power BI Developer · Microsoft Fabric certified (DP-600, DP-700), PL-300 ·
[GitHub](https://github.com/Joshua-S26) · [LinkedIn](https://www.linkedin.com/in/joshua-s26) · jshort26@sbcglobal.net
Data: Olist Brazilian E-Commerce Public Dataset (Kaggle), used non-commercially with attribution.
