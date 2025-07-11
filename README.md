## Daily PRA Nighttime Detection

> Last updated on: 11 Jul 2025, 12:31 (Japan Local Time)

![Latest PRA Plot](INTERMAGNET_DOWNLOADS/figures/PRA_20250711.png)

## Recent Anomaly Summary (Last 5 Anomalies)

| Observation range | Anomaly Time(s) | PRA Threshold | Anomalous PRA values | $S_Z$ during anomalies | $S_G$ during anomalies | Remarks | Plot |
|-------------------|------------------|----------------|------------------------|------------------------|------------------------|---------|------|
| 28/06/2025 20:00 - 29/06/2025 04:00 | 23:00–00:00 | 42.28 | 45.32 | 461.3211 | 10.1783 | Anomaly due to increase in S_Z | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250629.png) |
| 27/06/2025 20:00 - 28/06/2025 04:00 | 02:00–03:00 | 4.61 | 4.66 | 470.7228 | 101.0986 | Anomaly due to increase in S_Z | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250628.png) |
| 27/05/2025 20:00 - 28/05/2025 04:00 | 01:00–02:00 | 8.94 | 9.37 | 290.9852 | 31.0457 | Anomaly due to increase in S_Z | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250528.png) |
| 24/05/2025 20:00 - 25/05/2025 04:00 | 20:00–21:00 | 19.11 | 18.69 | 86.8499 | 4.6474 | Unable to determine (No prior data) | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250525.png) |
| 23/06/2025 20:00 - 24/06/2025 04:00 | 21:00–22:00 | 35.45 | 37.18 | 98.759 | 2.6559 | Anomaly due to drop in S_G | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250624.png) |

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
