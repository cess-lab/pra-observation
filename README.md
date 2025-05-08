## Daily PRA Nighttime Detection

> Last updated on: 08 May 2025, 12:21 (Japan Local Time)

![Latest PRA Plot](INTERMAGNET_DOWNLOADS/figures/PRA_20250508.png)

## Recent Anomaly Summary (Last 5 Anomalies)

| Observation range | Anomaly Time(s) | PRA Threshold | Anomalous PRA values | $S_Z$ during anomalies | $S_G$ during anomalies | Remarks | Plot |
|-------------------|------------------|----------------|------------------------|------------------------|------------------------|---------|------|
| 07/05/2025 20:00 - 08/05/2025 04:00 | 22:00–23:00, 23:00–00:00 | 34.43 | NaN | NaN | NaN | Anomalies mixed S_G/S_Z changes | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250508.png) |
| 06/05/2025 20:00 - 07/05/2025 04:00 | 22:00–23:00 | 5.16 | 5.600000e+00 | 8.603700e+01 | 1.537680e+01 | Anomalies due to drop in S_G | ![📈](INTERMAGNET_DOWNLOADS/figures/PRA_20250507.png) |

---
### About This Project
This repository provides automated daily analysis of nighttime geomagnetic field data
from the Kakioka observatory (KAK) using the Polarization Ratio Analysis (PRA) method.

- Detection Time Window: 20:00–04:00 (Local Time)
- Frequency Band: 0.01–0.05 Hz
- Anomalies flagged when PRA > threshold
- Threshold calculated based on weighted mean of recent days

### Author
- [Nur Syaiful Afrizal](https://github.com/syaifulafrizal)
