## Daily PRA Nighttime Detection

> Last updated on: 01 Aug 2025, 12:37 (Japan Local Time)

![Latest PRA Plot](INTERMAGNET_DOWNLOADS/figures/PRA_20250801.png)

## Recent Anomaly Summary (Last 5 Anomalies)

| Observation range | Anomaly Time(s) | PRA Threshold | Anomalous PRA values | $S_Z$ during anomalies | $S_G$ during anomalies | Remarks | Plot |
|-------------------|------------------|----------------|------------------------|------------------------|------------------------|---------|------|
| 31/07/2025 20:00 - 01/08/2025 04:00 | 00:00–01:00 | 5.95 | 6.5 | 52.8859 | 8.1334 | Anomaly due to drop in S_G | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250801.png) |
| 28/06/2025 20:00 - 29/06/2025 04:00 | 23:00–00:00 | 42.28 | 45.32 | 461.3211 | 10.1783 | Anomaly due to increase in S_Z | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250629.png) |
| 27/06/2025 20:00 - 28/06/2025 04:00 | 02:00–03:00 | 4.61 | 4.66 | 470.7228 | 101.0986 | Anomaly due to increase in S_Z | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250628.png) |
| 27/05/2025 20:00 - 28/05/2025 04:00 | 01:00–02:00 | 8.94 | 9.37 | 290.9852 | 31.0457 | Anomaly due to increase in S_Z | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250528.png) |
| 25/07/2025 20:00 - 26/07/2025 04:00 | 00:00–01:00 | 67.50 | 74.47 | 311.1924 | 4.1785 | Anomaly due to increase in S_Z | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250726.png) |

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
