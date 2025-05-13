## Daily PRA Nighttime Detection

> Last updated on: 13 May 2025, 17:04 (Japan Local Time)

![Latest PRA Plot](INTERMAGNET_DOWNLOADS/figures/PRA_20250513.png)

## Recent Anomaly Summary (Last 5 Anomalies)

| Observation range | Anomaly Time(s) | PRA Threshold | Anomalous PRA values | $S_Z$ during anomalies | $S_G$ during anomalies | Remarks | Plot |
|-------------------|------------------|----------------|------------------------|------------------------|------------------------|---------|------|
| 12/05/2025 20:00 - 13/05/2025 04:00 | 23:00–00:00 | 2.96 | 3.06 | 64.72 | 21.13 | Anomaly due to drop in S_G | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250513.png) |
| 12/05/2025 20:00 - 13/05/2025 04:00 | 23:00–00:00 | 2.96 | 3.06 | 64.72 | 21.13 | Anomaly due to drop in S_G | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250513.png) |
| 12/05/2025 20:00 - 13/05/2025 04:00 | 23:00–00:00 | 2.92 | 3.06 | 64.72 | 21.13 | Anomaly due to drop in S_G | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250513.png) |
| 12/05/2025 20:00 - 13/05/2025 04:00 | 23:00–00:00 | 2.92 | 3.06 | 64.72 | 21.13 | Anomaly due to drop in S_G | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250513.png) |
| 12/05/2025 20:00 - 13/05/2025 04:00 | 23:00–00:00 | 2.92 | 3.06 | 64.72 | 21.13 | Anomaly due to drop in S_G | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250513.png) |

---
### About This Project
This repository provides automated daily analysis of nighttime geomagnetic field data
from the Kakioka observatory (KAK) using the Polarization Ratio Analysis (PRA) method.

- Detection Time Window: 20:00–04:00 (Local Time)
- Frequency Band: 0.01–0.05 Hz
- Anomalies flagged when PRA > threshold
- Threshold calculated based on weighted mean of recent days
- Results stored in a cumulative `.mat` file for long-term monitoring
- README updated automatically each day via GitHub Actions

### Author
- [Nur Syaiful Afrizal](https://github.com/syaifulafrizal)
