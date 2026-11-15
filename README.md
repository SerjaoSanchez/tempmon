# tempmon

Monitor de temperatura de **CPU, GPU e SSD** direto no terminal, feito para Ubuntu (e outras distribuições Linux).
Um único script Python, sem dependências para instalar.

*[English version below](#english)*

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

## Recursos

- **CPU:** temperatura geral e por núcleo, uso, clock e RAM
- **GPU:** temperatura, uso, VRAM, clock, ventoinha e consumo
- **SSD NVMe:** temperatura e limite definido pelo fabricante
- **Histórico:** gráfico da temperatura dos últimos segundos, com pico e média da sessão
- **Aviso de throttling:** mostra quando a CPU ou a GPU está reduzindo o clock por temperatura
- **Log em CSV:** grava a sessão inteira para analisar depois (por exemplo, uma partida de jogo)
- **Configurável:** limites de temperatura, cores e intervalo num arquivo de texto
- **Layout adaptável:** painéis lado a lado em terminais largos, empilhados em terminais estreitos

### Hardware suportado

| Componente | Suporte | Fonte dos dados |
|---|---|---|
| CPU Intel | ✓ | driver `coretemp` |
| CPU AMD Ryzen | ✓ | driver `k10temp` ou `zenpower` |
| GPU NVIDIA | ✓ | `nvidia-smi` (driver proprietário) |
| GPU AMD Radeon | ✓ | driver `amdgpu` |
| SSD NVMe | ✓ | driver `nvme` |
| GPU Intel | ✗ | ainda não suportada |

## Instalação

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

## Uso

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

### Cores

| Cor | Significado (padrão para CPU) |
|---|---|
| verde | abaixo de 55 °C |
| amarelo | 55 a 69 °C |
| laranja | 70 a 84 °C |
| vermelho | 85 °C ou mais |

Os limites da GPU (75/85 °C) e do SSD (60/70 °C) são diferentes, e todos podem ser alterados na configuração.

## Configuração

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

## Log em CSV

Com `--log` ou `-o`, cada atualização vira uma linha no arquivo:

```
hora,cpu_temp_c,cpu_uso_pct,cpu_clock_mhz,ram_usada_gb,cpu_throttling,gpu_temp_c,gpu_uso_pct,gpu_vram_gb,gpu_clock_mhz,gpu_ventoinha_pct,gpu_consumo_w,gpu_throttling,ssd_netac_nvme_ssd_1tb_temp_c
2026-11-15T11:21:09,31.0,15.7,800,4.81,0,46.0,25.0,0.56,210,0,,0,38.9
```

O arquivo abre direto no LibreOffice Calc, Excel ou pandas. Campos que o hardware não informa ficam vazios.

## Limitações

- **Throttling em CPUs AMD:** o Linux não informa throttling de CPUs Ryzen. O tempmon considera que a CPU está no limite térmico a partir de `cpu_amd_limite` (padrão 89 °C, o limite da Ryzen 7 7800X3D). Ajuste para o seu modelo.
- **Throttling em GPUs AMD:** ainda não detectado.
- **Consumo da GPU:** algumas placas NVIDIA não informam o consumo pelo `nvidia-smi` e aparecem como N/D.
- **Ventoinhas do gabinete e do cooler:** não são exibidas (dependem do sensor da placa-mãe).

## Licença

[MIT](LICENSE)

---

<a id="english"></a>
## English

**tempmon** is a terminal temperature monitor for **CPU, GPU and NVMe SSD** on Ubuntu and other Linux distributions.
It is a single Python script with no dependencies. The interface is in Portuguese.

**Features:** per-core CPU temperatures, GPU temperature/load/VRAM/clock/fan/power, NVMe temperature,
temperature history graph with session peak and average, thermal throttling alerts, CSV session logging,
a TOML config file (thresholds, colors, refresh interval) and a responsive side-by-side or stacked layout.

**Supported hardware:** Intel CPUs (`coretemp`), AMD Ryzen CPUs (`k10temp`/`zenpower`),
NVIDIA GPUs (`nvidia-smi`), AMD Radeon GPUs (`amdgpu`) and NVMe SSDs.

**Install** (Python 3.8+, no sudo needed):

```bash
curl -fsSL https://raw.githubusercontent.com/SerjaoSanchez/tempmon/main/install.sh | bash
```

**Usage:**

```bash
tempmon                 # refresh every second
tempmon 2               # refresh every 2 seconds
tempmon --log           # log the session to ~/tempmon-logs/*.csv
tempmon -o game.csv     # log the session to a specific file
tempmon --config        # print the config file path (~/.config/tempmon/config.toml)
```

Press `q` or `Ctrl+C` to quit; a session summary (peak and average temperatures, throttling events) is printed on exit.
On Python 3.10 or older, install `python3-tomli` to enable the config file.

**Limitations:** Linux does not report thermal throttling for AMD Ryzen CPUs, so tempmon flags it when the
temperature reaches `cpu_amd_limite` (default 89 °C). Throttling detection for AMD GPUs and chassis fan speeds
are not supported yet.

License: [MIT](LICENSE).
