## Daily PRA Nighttime Detection

> Last updated on: 13 Oct 2025, 12:21 (Japan Local Time)

![Latest PRA Plot](INTERMAGNET_DOWNLOADS/figures/PRA_20251013.png)

## Recent Anomaly Summary (Last 5 Anomalies)

| Observation range | Anomaly Time(s) | PRA Threshold | Anomalous PRA values | $S_Z$ during anomalies | $S_G$ during anomalies | Remarks | Plot |
|-------------------|------------------|----------------|------------------------|------------------------|------------------------|---------|------|
| 31/07/2025 20:00 - 01/08/2025 04:00 | 00:00–01:00 | 5.95 | 6.5 | 52.8859 | 8.1334 | Anomaly due to drop in S_G | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250801.png) |
| 29/09/2025 20:00 - 30/09/2025 04:00 | 00:00–01:00 | 13.08 | 14.42 | 96.6674 | 6.7017 | Anomaly due to increase in S_Z | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250930.png) |
| 29/08/2025 20:00 - 30/08/2025 04:00 | 01:00–02:00 | 41.16 | 44.31 | 160.9535 | 3.6324 | Anomaly due to drop in S_G | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250830.png) |
| 28/08/2025 20:00 - 29/08/2025 04:00 | 22:00–23:00 | 9.14 | 9.57 | 232.4795 | 24.3005 | Anomaly due to increase in S_Z | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250829.png) |
| 28/06/2025 20:00 - 29/06/2025 04:00 | 23:00–00:00 | 42.28 | 45.32 | 461.3211 | 10.1783 | Anomaly due to increase in S_Z | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250629.png) |

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
