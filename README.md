## Daily PRA Nighttime Detection

> Last updated on: 15 Nov 2025, 12:20 (Japan Local Time)

![Latest PRA Plot](INTERMAGNET_DOWNLOADS/figures/PRA_20251115.png)

## Recent Anomaly Summary (Last 5 Anomalies)

| Observation range | Anomaly Time(s) | PRA Threshold | Anomalous PRA values | $S_Z$ during anomalies | $S_G$ during anomalies | Remarks | Plot |
|-------------------|------------------|----------------|------------------------|------------------------|------------------------|---------|------|
| 31/07/2025 20:00 - 01/08/2025 04:00 | 00:00–01:00 | 5.95 | 6.5 | 52.8859 | 8.1334 | Anomaly due to drop in S_G | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250801.png) |
| 30/10/2025 20:00 - 31/10/2025 04:00 | 21:00–22:00, 00:00–01:00 | 12.40 | - | - | - | Anomaly due to increase in S_Z, Anomaly due to drop in S_G | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20251031.png) |
| 29/09/2025 20:00 - 30/09/2025 04:00 | 00:00–01:00 | 13.08 | 14.42 | 96.6674 | 6.7017 | Anomaly due to increase in S_Z | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250930.png) |
| 29/08/2025 20:00 - 30/08/2025 04:00 | 01:00–02:00 | 41.16 | 44.31 | 160.9535 | 3.6324 | Anomaly due to drop in S_G | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250830.png) |
| 28/10/2025 20:00 - 29/10/2025 04:00 | 20:00–21:00 | 6.77 | 7.34 | 81.4302 | 11.0995 | Unable to determine (No prior data) | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20251029.png) |

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
