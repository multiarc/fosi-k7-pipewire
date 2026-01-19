# Fosi Audio K7 DAC/Amp - PipeWire Configuration

This package provides PipeWire and WirePlumber configuration files for the **Fosi Audio K7** DAC/Amp, enabling seamless support for both UAC 1.0 and UAC 2.0 modes on Linux.

## Device Specifications

- **DAC Chip**: AKM AK4493SEQ
- **USB Interface**: XMOS XU208
- **Headphone Amp**: Dual TPA6120A2
- **Op-Amp**: OPA1612
- **Bluetooth Module**: Qualcomm QCC3031 (Bluetooth 5.0)
- **USB Modes**: UAC 1.0 / UAC 2.0 (switchable via button on device)

### UAC 2.0 Mode (High Resolution)
- PCM: Up to 32-bit / 384kHz
- DSD: Native DSD up to DSD256
- Sample rates: 44.1, 48, 88.2, 96, 176.4, 192, 352.8, 384 kHz
- **No microphone input**

### UAC 1.0 Mode (Compatibility + Microphone)
- PCM: 16-bit / 48kHz only
- **Microphone input available**
- Simultaneous recording and playback

## Requirements

- Linux with PipeWire audio server
- WirePlumber session manager
- USB audio support in kernel

### Tested On
- Ubuntu 22.04+ / 24.04
- Fedora 38+
- Arch Linux
- Any distribution with PipeWire 0.3.50+

## Installation

```bash
# Make the install script executable
chmod +x install.sh

# Run the installer
./install.sh
```

The installer will:
1. Check for PipeWire and WirePlumber
2. Install configuration files to `~/.config/`
3. Restart WirePlumber to apply changes

## Uninstallation

```bash
./install.sh --remove
```

## Usage

### Switch UAC Mode
Press the **UAC button** on the Fosi Audio K7 device to toggle between modes.

The device will disconnect and reconnect in the new mode. PipeWire/WirePlumber will automatically detect the mode and apply appropriate settings.

## Configuration Files

| File | Purpose |
|------|---------|
| `~/.config/pipewire/pipewire.conf.d/10-fosi-audio-k7.conf` | PipeWire global settings |
| `~/.config/wireplumber/main.lua.d/51-fosi-audio-k7.lua` | Node-level audio settings |
| `~/.config/wireplumber/main.lua.d/52-fosi-audio-k7-profile.lua` | Profile priority settings |
| `~/.config/wireplumber/wireplumber.conf.d/51-fosi-audio-k7.conf` | Device profile rules |

## DSD Playback (UAC 2.0 Mode Only)

The K7 supports DSD via two methods:

### DoP (DSD over PCM) - Through PipeWire
- DSD64 (2.8MHz) → transmitted as 176.4kHz PCM
- DSD128 (5.6MHz) → transmitted as 352.8kHz PCM

### Native DSD - Bypassing PipeWire (Best Quality)
```bash
# Using mpv
mpv --audio-device=alsa/hw:K7,0 --audio-spdif=dsd your-file.dsf
```

### Recommended Players
- **MPV**: DoP support, configure with `--audio-device=alsa/hw:K7,0`
- **Deadbeef**: GUI player with DSD plugin
- **Strawberry**: Qt player with native DSD support

## Troubleshooting

### No Audio Output
1. Check if device is detected: `cat /proc/asound/cards | grep K7`
2. Check PipeWire status: `systemctl --user status pipewire`
3. Restart WirePlumber: `systemctl --user restart wireplumber`

### No Microphone Input
- Microphone is only available in **UAC 1.0 mode**
- Press the UAC button to switch modes

### Audio Crackling/Glitches
Try increasing buffer sizes in the Lua configuration:
```lua
["api.alsa.period-size"] = 4096,
["api.alsa.headroom"] = 4096,
```

### Wrong Sample Rate
The configuration automatically selects the appropriate rate based on UAC mode. If stuck at wrong rate:
```bash
systemctl --user restart wireplumber
```

## License

This configuration is provided as-is for personal use with the Fosi Audio K7 DAC/Amp.

## Credits

Configuration created for optimal Fosi Audio K7 support on Linux with PipeWire.
