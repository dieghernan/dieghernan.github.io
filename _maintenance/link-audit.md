# Link audit tracker

Updated: 2026-10-07. This maintenance directory is excluded from normal Jekyll output by its leading underscore.

A timeout, crawler failure, server 403 or environment proxy denial does not establish a broken link. Current external checks were blocked by the environment network policy; no new remote availability conclusions are drawn from them.

| Reference | Status | Files and action |
| --- | --- | --- |
| pmkey.xyz | Confirmed broken in the previous audit; links removed | Bzel, Sfera, 7egment and TextWatchClima: historical Master Key integration preserved; service signup instructions removed. |
| fontastic.me | Doubtful destination; reference resolved conservatively | Bzel and TextWatchClima: links removed; Fontastic attribution preserved. Remote availability remains unverified. |
| switchfromshapefile.org | Retained at the user’s request; doubtful destination | Link preserved in both `_Rmd/2026-02-12-geobounds.Rmd` and `collections/_posts/2026-02-12-geobounds.md`. Remote availability remains unverified. |
| CIA legacy World Factbook index and appendix URLs | Obsolete historical references; links removed | CountryCodes: CIA attribution, historical data provenance and FIPS description preserved. No equivalent modern destination assumed. |
| https://rki.de/risikogebiete | Pending manual review | `collections/_posts/2022-03-14-Corona-timelapse.md`: retained. Previous crawler 403 is inconclusive; verify historical relevance and destination manually. |
| https://twitter.com/spainmunic?ref_src=twsrc%5Etfw | Pending manual review | `collections/_projects/spain-munic-bot.md`: timeline retained. Crawler restrictions are not evidence of a broken account link. |

Already resolved: REST Countries now uses `https://restcountries.com/`; Maungawhau uses `https://www.geomorphometry.org/2009/08/20/volcano-maungawhau/`.

Do not reopen the completed sitemap audit based only on crawler failures. Paul Murrell was not a broken link. The archive hierarchy is intentional. Categories, search and pagination exist in gh-pages. Do not remove or classify the 7segment page as broken without verification; its source file is named `7egment.md`.
