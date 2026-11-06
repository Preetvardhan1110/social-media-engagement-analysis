# Social Media Engagement Analysis — SQL Project

**Author:** Preetvardhan Kushwaha  
**Project type:** SQL data analysis / stakeholder briefing  
**Database context:** Instagram-style social media dataset  
**Analysis date shown in presentation:** 4 November 2026

## Project overview

This project uses SQL to analyse user activity and content engagement in an Instagram-style database. The central business question is:

> How can user activity data help identify valuable users, re-engage inactive users, and guide content and campaign strategy?

The analysis covers user-generated posts, likes, comments, follows, hashtags, and photo-tag relationships. It translates query results into practical recommendations for creator recognition, user reactivation, content testing, and better data collection.

## Dataset snapshot

| Metric | Records |
|---|---:|
| Users | 100 |
| Photo posts | 257 |
| Likes | 8,782 |
| Comments | 7,488 |
| Follow relationships | 7,623 |
| Photo-tag links | 501 |
| Distinct tags | 21 |

The project briefing reports no missing values or duplicate-key issues in the checked fields.

## Key findings

- **Engagement mix:** 8,782 likes versus 7,488 comments; likes are approximately 17% higher.
- **Tag usage:** 501 tag links across 257 photo posts, or an average of **1.9494 tags per post** (including untagged posts in the denominator).
- **Creator engagement:** Eveline95 ranks first in the presentation's combined activity score with **749** (420 likes and 329 comments received).
- **Reactivation opportunity:** **13 of 100 users** have no recorded activity in the dataset; the 60-day inactivity rule is measured relative to the dataset's latest activity date, not the current date.
- **Hashtag performance:** The top 10 hashtags average between **34.47 and 35.75 likes per photo**. The differences are narrow, so sample volume and sample size matter.
- **Data limitation:** The supplied schema contains photo posts, not video/reel content, and does not include demographic attributes, ad impressions, clicks, or conversions.

## Analysis workflow

1. Inspect the schema, relationships, keys, and available date fields.
2. Check selected tables for NULL values and duplicate business keys.
3. Aggregate likes and comments at the photo level before joining to avoid join fan-out.
4. Use CTEs and joins to calculate user-, creator-, and hashtag-level metrics.
5. Rank users and identify inactive accounts and high-performing tags.
6. Interpret the findings, state limitations, and recommend measurable next steps.

## SQL concepts demonstrated

- `INNER JOIN` and `LEFT JOIN`
- Common Table Expressions (CTEs)
- `GROUP BY` and aggregate functions (`COUNT`, `SUM`, `AVG`)
- `COALESCE` and `NULLIF`
- `UNION ALL`
- Window functions (`RANK() OVER`)
- Subqueries and conditional segmentation (`CASE`)
- Data-quality checks and a controlled `UPDATE` example

## Repository structure

```text
social-media-engagement-analysis/
├── README.md
├── sql/
│   ├── social_media_analysis.sql
│   └── original_student_template.sql
├── presentation/
│   └── Social Media Engagement Analysis — SQL Project.pptx
└── documentation/
    └── Tasks-Social-Media(3).docx
```

## How to use

1. Create or select the `ig_clone` database in a MySQL environment.
2. Load the source dataset and confirm that the expected tables exist: `users`, `photos`, `comments`, `likes`, `follows`, `tags`, and `photo_tags`.
3. Open `sql/social_media_analysis.sql` in MySQL Workbench or another compatible MySQL client.
4. Execute the sections in order and compare the outputs with the row-count expectations in the task sheet.

**Important:** The script is written for a MySQL-style environment. The project files contain analysis queries and assumed table names; the dataset itself is not included in this repository. The final `UPDATE` example assumes a `User_Interactions` table and should only be run against a matching test table, after reviewing the affected rows.

## Recommendations derived from the analysis

1. Recognise consistently valuable creators, but validate unusual score patterns before awarding incentives.
2. Run a targeted win-back campaign for users with no recorded activity.
3. Test hashtag-led content rather than assuming a tag causes higher engagement.
4. Collect content-type, consented demographic, and campaign-performance data to support stronger segmentation and ROI measurement.

## Limitations and interpretation

- Activity counts are proxies for user value; they do not directly measure loyalty or lifetime value.
- Hashtag averages should be interpreted alongside the number of posts behind each average.
- Correlation does not establish causation.
- The dataset does not support demographic conclusions or comparisons between photos, videos, and reels.
- The 60-day inactivity calculation is relative to the dataset's maximum activity date.

## Files

- **SQL analysis:** `sql/social_media_analysis.sql`
- **Original SQL template:** `sql/original_student_template.sql`
- **Stakeholder presentation:** `presentation/`
- **Task sheet and written interpretations:** `documentation/`

---
*Prepared as a portfolio project demonstrating SQL querying, data validation, aggregation, ranking, segmentation, and business interpretation.*
