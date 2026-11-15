# tempmon

A terminal temperature monitor for **CPU, GPU and NVMe SSD** on Ubuntu and other Linux distributions.
A single Python script with no dependencies to install.

*[Versão em português abaixo](#portugues)*

```
╭─ CPU ───────────────────────────────────────────────────────╮ ╭─ GPU ───────────────────────────────────────────────────────╮
│ Intel Core i5-8600K                                         │ │ GeForce RTX 4060                                            │
│ ✓ sem throttling térmico                                    │ │ ✓ sem throttling térmico                                    │
│                                                             │ │                                                             │
│ Temp    ██████████▌────────────────────── 32.0°C   máx 43°  │ │ Temp    ██████████████▊────────────────── 45.0°C   máx 45°  │
│         ······▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▂▁▁▁▁          méd 32°  │ │         ······▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂          méd 45°  │
│ Uso     █████▋─────────────────────────── 17%               │ │ Uso     █████████████▊─────────────────── 42%               │
│ RAM     ██████████▎────────────────────── 4.8 GB   de 16 GB │ │ VRAM    ██▎────────────────────────────── 0.6 GB   de 8 GB  │
│ Clock   800 MHz                                             │ │ Clock   210 MHz         Ventoinha 0%                        │
│                                                             │ │ Consumo N/D / 115 W                                         │
│ Núc 0 ████▉───────────  31°   Núc 1 ████▉───────────  31°   │ │                                                             │
│ Núc 2 ████▊───────────  30°   Núc 3 ████▋───────────  29°   │ │                                                             │
│ Núc 4 ████▋───────────  29°   Núc 5 ████▊───────────  30°   │ │                                                             │
╰─────────────────────────────────────────────────────────────╯ ╰─────────────────────────────────────────────────────────────╯
╭─ SSD ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Netac NVMe SSD 1TB  ·  limite do fabricante 90°C                                                                            │
│ Temp    ██████████████████████████████████▏───────────────────────────────────────────────────── 38.9°C   máx 40°  méd 39°  │
╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

> The interface is currently in Portuguese (e.g. *Temp*, *Uso* = load, *máx* = peak, *méd* = average, *Núc* = core).

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
Resumo da sessão (00:42:10)
  CPU                    máx  71.0°C   méd  58.3°C   throttling: nenhum
  GPU                    máx  68.0°C   méd  61.2°C   throttling: nenhum
  SSD Netac NVMe SSD 1TB máx  45.9°C   méd  42.1°C
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
intervalo = 1.0          # refresh interval in seconds

[limites]                # thresholds in °C
cpu_alerta = 70          # warning
cpu_critico = 85         # critical
gpu_alerta = 75
gpu_critico = 85

[exibir]                 # what to show
nucleos = true           # per-core temperatures
ssd = true               # SSD panel
```

Invalid values are ignored (with a warning at the top of the screen) and the default is used instead.
Delete the file to restore all defaults.
On Python 3.10 or older (Ubuntu 22.04), the config file needs the `python3-tomli` package:
`sudo apt install python3-tomli`.

## CSV logging

With `--log` or `-o`, every refresh becomes a line in the file:

```
hora,cpu_temp_c,cpu_uso_pct,cpu_clock_mhz,ram_usada_gb,cpu_throttling,gpu_temp_c,gpu_uso_pct,gpu_vram_gb,gpu_clock_mhz,gpu_ventoinha_pct,gpu_consumo_w,gpu_throttling,ssd_netac_nvme_ssd_1tb_temp_c
2026-11-15T11:21:09,31.0,15.7,800,4.81,0,46.0,25.0,0.56,210,0,,0,38.9
```

The file opens directly in LibreOffice Calc, Excel or pandas. Fields the hardware does not report are left empty.
Column names are in Portuguese: `hora` = time, `uso` = load, `ventoinha` = fan, `consumo` = power draw.

## Limitations

- **Throttling on AMD CPUs:** Linux does not report thermal throttling for Ryzen CPUs. tempmon flags it when the temperature reaches `cpu_amd_limite` (default 89 °C, the limit of the Ryzen 7 7800X3D). Adjust it for your model.
- **Throttling on AMD GPUs:** not detected yet.
- **GPU power draw:** some NVIDIA cards do not report power through `nvidia-smi` and show N/D.
- **Case and cooler fans:** not shown (they depend on the motherboard sensor).

## License

[MIT](LICENSE)

---

<a id="portugues"></a>
## Português

Monitor de temperatura de **CPU, GPU e SSD** direto no terminal, feito para Ubuntu (e outras distribuições Linux).
Um único script Python, sem dependências para instalar.

### Recursos

- **CPU:** temperatura geral e por núcleo, uso, clock e RAM
- **GPU:** temperatura, uso, VRAM, clock, ventoinha e consumo
- **SSD NVMe:** temperatura e limite definido pelo fabricante
- **Histórico:** gráfico da temperatura dos últimos segundos, com pico e média da sessão
- **Aviso de throttling:** mostra quando a CPU ou a GPU está reduzindo o clock por temperatura
- **Log em CSV:** grava a sessão inteira para analisar depois (por exemplo, uma partida de jogo)
- **Configurável:** limites de temperatura, cores e intervalo num arquivo de texto
- **Layout adaptável:** painéis lado a lado em terminais largos, empilhados em terminais estreitos

#### Hardware suportado

| Componente | Suporte | Fonte dos dados |
|---|---|---|
| CPU Intel | ✓ | driver `coretemp` |
| CPU AMD Ryzen | ✓ | driver `k10temp` ou `zenpower` |
| GPU NVIDIA | ✓ | `nvidia-smi` (driver proprietário) |
| GPU AMD Radeon | ✓ | driver `amdgpu` |
| SSD NVMe | ✓ | driver `nvme` |
| GPU Intel | ✗ | ainda não suportada |

### Instalação

Requer Python 3.8 ou mais novo (já vem no Ubuntu 20.04 em diante).

```bash
curl -fsSL https://raw.githubusercontent.com/SerjaoSanchez/tempmon/main/install.sh | bash
```

Ou clonando o repositório:

```bash
git clone https://github.com/SerjaoSanchez/tempmon.git
cd tempmon
./install.sh
```

O programa é instalado em `~/.local/bin/tempmon`, sem precisar de `sudo`.
Para remover: `./install.sh --uninstall`.

### Uso

```bash
tempmon                 # atualiza a cada 1 segundo
tempmon 2               # atualiza a cada 2 segundos
tempmon --log           # grava a sessão em ~/tempmon-logs/tempmon_DATA_HORA.csv
tempmon -o jogo.csv     # grava a sessão no arquivo indicado
tempmon --config        # mostra onde fica o arquivo de configuração
tempmon --version
```

Aperte `q` ou `Ctrl+C` para sair. Ao sair, aparece um resumo da sessão:

```
Resumo da sessão (00:42:10)
  CPU                    máx  71.0°C   méd  58.3°C   throttling: nenhum
  GPU                    máx  68.0°C   méd  61.2°C   throttling: nenhum
  SSD Netac NVMe SSD 1TB máx  45.9°C   méd  42.1°C
```

#### Cores

| Cor | Significado (padrão para CPU) |
|---|---|
| verde | abaixo de 55 °C |
| amarelo | 55 a 69 °C |
| laranja | 70 a 84 °C |
| vermelho | 85 °C ou mais |

Os limites da GPU (75/85 °C) e do SSD (60/70 °C) são diferentes, e todos podem ser alterados na configuração.

### Configuração

Na primeira execução é criado o arquivo `~/.config/tempmon/config.toml`, todo comentado. Exemplo:

```toml
intervalo = 1.0

[limites]
cpu_alerta = 70
cpu_critico = 85
gpu_alerta = 75
gpu_critico = 85

[exibir]
nucleos = true
ssd = true
```

Valores inválidos são ignorados (com aviso no topo da tela) e o padrão é usado no lugar.
Para restaurar tudo, basta apagar o arquivo.
No Python 3.10 ou anterior (Ubuntu 22.04), o arquivo de configuração precisa do pacote `python3-tomli`:
`sudo apt install python3-tomli`.

### Log em CSV

Com `--log` ou `-o`, cada atualização vira uma linha no arquivo:

```
hora,cpu_temp_c,cpu_uso_pct,cpu_clock_mhz,ram_usada_gb,cpu_throttling,gpu_temp_c,gpu_uso_pct,gpu_vram_gb,gpu_clock_mhz,gpu_ventoinha_pct,gpu_consumo_w,gpu_throttling,ssd_netac_nvme_ssd_1tb_temp_c
2026-11-15T11:21:09,31.0,15.7,800,4.81,0,46.0,25.0,0.56,210,0,,0,38.9
```

O arquivo abre direto no LibreOffice Calc, Excel ou pandas. Campos que o hardware não informa ficam vazios.

### Limitações

- **Throttling em CPUs AMD:** o Linux não informa throttling de CPUs Ryzen. O tempmon considera que a CPU está no limite térmico a partir de `cpu_amd_limite` (padrão 89 °C, o limite da Ryzen 7 7800X3D). Ajuste para o seu modelo.
- **Throttling em GPUs AMD:** ainda não detectado.
- **Consumo da GPU:** algumas placas NVIDIA não informam o consumo pelo `nvidia-smi` e aparecem como N/D.
- **Ventoinhas do gabinete e do cooler:** não são exibidas (dependem do sensor da placa-mãe).

### Licença

[MIT](LICENSE)
