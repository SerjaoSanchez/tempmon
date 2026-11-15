# tempmon

A terminal temperature monitor for **CPU, GPU and NVMe SSD** on Ubuntu and other Linux distributions.
A single Python script with no dependencies to install.

```
╭─ CPU ───────────────────────────────────────────────────────╮ ╭─ GPU ───────────────────────────────────────────────────────╮
│ Intel Core i5-8600K                                         │ │ GeForce RTX 4060                                            │
│ ✓ no thermal throttling                                     │ │ ✓ no thermal throttling                                     │
│                                                             │ │                                                             │
│ Temp    ███████████▏───────────────────── 34.0°C   max 43°  │ │ Temp    ██████████████▊────────────────── 45.0°C   max 45°  │
│         ······▁▁▁▂▁▁▁▁▁▁▁▁▂▁▁▁▂▁▁▁▁▁▁▁▁▁▁          avg 34°  │ │         ······▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂          avg 45°  │
│ Load    █████████──────────────────────── 28%               │ │ Load    █████▎─────────────────────────── 16%               │
│ RAM     ██████████▊────────────────────── 5.1 GB   of 16 GB │ │ VRAM    ██▌────────────────────────────── 0.6 GB   of 8 GB  │
│ Clock   2,000 MHz                                           │ │ Clock   390 MHz         Fan 0%                              │
│                                                             │ │ Power   N/A / 115 W                                         │
│ Core 0 ████▋──────────  31°   Core 1 █████──────────  34°   │ │                                                             │
│ Core 2 ████▋──────────  31°   Core 3 ████▋──────────  31°   │ │                                                             │
│ Core 4 ████▋──────────  31°   Core 5 ████▋──────────  31°   │ │                                                             │
╰─────────────────────────────────────────────────────────────╯ ╰─────────────────────────────────────────────────────────────╯
╭─ SSD ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Netac NVMe SSD 1TB  ·  manufacturer limit 90°C                                                                              │
│ Temp    ██████████████████████████████████▏───────────────────────────────────────────────────── 38.9°C   max 40°  avg 39°  │
╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

## Features

- **CPU:** package and per-core temperatures, load, clock and RAM usage
- **GPU:** temperature, load, VRAM, clock, fan speed and power draw
- **NVMe SSD:** temperature and the manufacturer's thermal limit
- **History:** temperature graph of the last seconds, with session peak and average
- **Throttling alerts:** shows when the CPU or GPU is lowering its clock because of heat
- **CSV logging:** record a whole session to analyze later (a gaming session, for example)
- **Configurable:** temperature thresholds, colors and refresh interval in a plain text file
- **Responsive layout:** side-by-side panels on wide terminals, stacked on narrow ones

### Supported hardware

| Component | Supported | Data source |
|---|---|---|
| Intel CPU | ✓ | `coretemp` driver |
| AMD Ryzen CPU | ✓ | `k10temp` or `zenpower` driver |
| NVIDIA GPU | ✓ | `nvidia-smi` (proprietary driver) |
| AMD Radeon GPU | ✓ | `amdgpu` driver |
| NVMe SSD | ✓ | `nvme` driver |
| Intel GPU | ✗ | not supported yet |

## Installation

Requires Python 3.8 or newer (included in Ubuntu 20.04 and later).

```bash
curl -fsSL https://raw.githubusercontent.com/SerjaoSanchez/tempmon/main/install.sh | bash
```

Or clone the repository:

```bash
git clone https://github.com/SerjaoSanchez/tempmon.git
cd tempmon
./install.sh
```

The program is installed to `~/.local/bin/tempmon`; no `sudo` needed.
To uninstall: `./install.sh --uninstall`.

## Usage

```bash
tempmon                 # refresh every second
tempmon 2               # refresh every 2 seconds
tempmon --log           # log the session to ~/tempmon-logs/tempmon_DATE_TIME.csv
tempmon -o game.csv     # log the session to a specific file
tempmon --config        # print the config file path
tempmon --version
```

Press `q` or `Ctrl+C` to quit. A session summary is printed on exit:

```
Session summary (00:42:10)
  CPU                    max  71.0°C   avg  58.3°C   throttling: none
  GPU                    max  68.0°C   avg  61.2°C   throttling: none
  SSD Netac NVMe SSD 1TB max  45.9°C   avg  42.1°C
```

### Colors

| Color | Meaning (CPU defaults) |
|---|---|
| green | below 55 °C |
| yellow | 55 to 69 °C |
| orange | 70 to 84 °C |
| red | 85 °C or higher |

GPU (75/85 °C) and SSD (60/70 °C) thresholds differ, and all of them can be changed in the config file.

## Configuration

On first run, tempmon creates `~/.config/tempmon/config.toml` with comments explaining each option. Example:

```toml
interval = 1.0           # seconds between refreshes

[thresholds]             # °C
cpu_warn = 70
cpu_critical = 85
gpu_warn = 75
gpu_critical = 85

[show]
cores = true             # per-core temperatures
ssd = true               # SSD panel
```

Invalid values are ignored (with a warning at the top of the screen) and the default is used instead.
Delete the file to restore all defaults.
On Python 3.10 or older (Ubuntu 22.04), the config file needs the `python3-tomli` package:
`sudo apt install python3-tomli`.

## CSV logging

With `--log` or `-o`, every refresh becomes a line in the file:

```
time,cpu_temp_c,cpu_load_pct,cpu_clock_mhz,ram_used_gb,cpu_throttling,gpu_temp_c,gpu_load_pct,gpu_vram_gb,gpu_clock_mhz,gpu_fan_pct,gpu_power_w,gpu_throttling,ssd_netac_nvme_ssd_1tb_temp_c
2026-11-15T11:21:09,31.0,15.7,800,4.81,0,46.0,25.0,0.56,210,0,,0,38.9
```

The file opens directly in LibreOffice Calc, Excel or pandas. Fields the hardware does not report are left empty.

## Limitations

- **Throttling on AMD CPUs:** Linux does not report thermal throttling for Ryzen CPUs. tempmon flags it when the temperature reaches `cpu_amd_limit` (default 89 °C, the limit of the Ryzen 7 7800X3D). Adjust it for your model.
- **Throttling on AMD GPUs:** not detected yet.
- **GPU power draw:** some NVIDIA cards do not report power through `nvidia-smi` and show N/A.
- **Case and cooler fans:** not shown (they depend on the motherboard sensor).

## License

[MIT](LICENSE)
