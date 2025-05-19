## Daily PRA Nighttime Detection

> Last updated on: 19 May 2025, 12:25 (Japan Local Time)

![Latest PRA Plot](INTERMAGNET_DOWNLOADS/figures/PRA_20250519.png)

## Recent Anomaly Summary (Last 5 Anomalies)

| Observation range | Anomaly Time(s) | PRA Threshold | Anomalous PRA values | $S_Z$ during anomalies | $S_G$ during anomalies | Remarks | Plot |
|-------------------|------------------|----------------|------------------------|------------------------|------------------------|---------|------|
| 16/05/2025 20:00 - 17/05/2025 04:00 | 20:00–21:00 | 10.87 | 11.73 | 45.9805 | 3.9187 | Unable to determine (No prior data) | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250517.png) |
| 13/05/2025 20:00 - 14/05/2025 04:00 | 20:00–21:00 | 7.67 | 6.91 | 78.0037 | 11.2962 | No prior data | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250514.png) |
| 12/05/2025 20:00 - 13/05/2025 04:00 | 23:00–00:00 | 2.96 | 3.06 | 64.7152 | 21.1348 | Anomaly due to drop in S_G | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250513.png) |
| 08/05/2025 20:00 - 09/05/2025 04:00 | 20:00–21:00 | 30.56 | 33.89 | 84.7088 | 2.4998 | Unable to determine cause (no prior sample) | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250509.png) |
| 07/05/2025 20:00 - 08/05/2025 04:00 | 22:00–23:00, 23:00–00:00 | 34.43 | - | - | - | Anomalies mixed S_G/S_Z changes | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250508.png) |

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
