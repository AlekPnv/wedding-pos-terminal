# Setup Guide

End-to-end setup for the POS terminal, from a blank SD card to a device that
auto-starts on boot. Assumes you know your way around a terminal and have used
a Raspberry Pi before. No hand-holding, but nothing skipped either.

---

## 1. Prerequisites

- Raspberry Pi Zero WH (or any Pi with a 40-pin header)
- MicroSD card, 16 GB+
- The components from the [Bill of Materials](../hardware/bom.md), wired per the
  table below
- A computer with the Raspberry Pi Imager installed
- Your WiFi credentials (2.4 GHz; the Zero W has no 5 GHz radio)

---

## 2. Flash the OS

Use **Raspberry Pi Imager**.

1. Choose OS → **Raspberry Pi OS Lite (32-bit)**. No desktop needed, since this
   is headless.
2. Click the gear / **Edit Settings** before writing and set:
   - Hostname: `weddingpos` (optional)
   - Enable **SSH** → use password authentication (or drop in your public key)
   - Set username + password (e.g. user `pi`)
   - Configure **WiFi**: SSID, password, and your country code
   - Set locale / timezone
3. Write to the card, then eject and boot the Pi.

Give it about 60 to 90 seconds on first boot to expand the filesystem and join
WiFi.

---

## 3. First SSH connection

Find the Pi's IP address. The easy path is your router's device list.

```bash
ssh pi@<pi-ip-address>
```

> **Windows note:** `weddingpos.local` only resolves if Apple Bonjour / mDNS is
> installed (it ships with iTunes and a few other apps). If `ssh pi@weddingpos.local`
> hangs, don't fight it. Grab the IP from your router and SSH to that instead.

Once in, enable the two buses the hardware needs:

```bash
sudo raspi-config
```

Go to **Interface Options** and enable **SPI** (for the RC522) and **I2C** (for
the OLED). Finish and reboot when prompted.

After the reboot, sanity-check that both devices show up:

```bash
sudo apt install -y i2c-tools
i2cdetect -y 1        # OLED should appear at address 0x3C
```

---

## 4. Install dependencies

```bash
sudo apt update
sudo apt install -y python3-pip python3-dev git
# On Bookworm you may need --break-system-packages, or use a venv
pip3 install luma.oled mfrc522 RPi.GPIO spidev
```

`luma.oled` drives the SSD1306 over I2C; `mfrc522` handles the RFID reader over
SPI; `RPi.GPIO` runs the buzzer.

---

## 5. Wiring

Power everything off before wiring. Double-check the RC522 voltage: 3.3V, not 5V.

| Component | Pin | Notes |
|-----------|-----|-------|
| OLED VCC | Pin 1 (3.3V) | |
| OLED GND | Pin 6 (GND) | |
| OLED SDA | Pin 3 (GPIO 2) | |
| OLED SCL | Pin 5 (GPIO 3) | |
| RC522 VCC | Pin 17 (3.3V) | NOT 5V, will damage it |
| RC522 GND | Pin 25 (GND) | |
| RC522 RST | Pin 22 (GPIO 25) | |
| RC522 SDA/CS | Pin 24 (GPIO 8) | |
| RC522 MOSI | Pin 19 (GPIO 10) | |
| RC522 MISO | Pin 21 (GPIO 9) | |
| RC522 SCK | Pin 23 (GPIO 11) | |
| Buzzer VCC | Pin 2 (5V) | |
| Buzzer GND | Pin 14 (GND) | |
| Buzzer I/O | Pin 11 (GPIO 17) | |

The three buttons on the front of the case are wired (GPIO 23 / 24 / 27 to GND)
but the script never reads them. They're purely a physical design detail. Skip
them if you like.

See [../hardware/wiring_diagram.svg](../hardware/wiring_diagram.svg) for the
visual version.

---

## 6. Transfer the script and configure

Copy `pos_terminal.py` to the Pi (from your computer):

```bash
scp pos_terminal.py pi@<pi-ip-address>:/home/pi/
```

Then edit the config block at the top to taste:

```python
AMOUNT          = "10,000.00"
CURRENCY        = "EUR"
APPROVED_LINE1  = "Congratulations!"
APPROVED_LINE2  = "Enjoy the show ;)"
PROCESSING_SECS = 4
```

Test it manually first:

```bash
python3 /home/pi/pos_terminal.py
```

You should get the splash screen, then the idle "TAP CARD TO PAY" screen. Tap a
card and it should run the animation and approve. `Ctrl+C` to stop.

---

## 7. Auto-start on boot

Raspberry Pi OS Bookworm has no `/etc/rc.local`, so use cron. Edit the crontab:

```bash
crontab -e
```

Add this line at the bottom:

```
@reboot sleep 15 && /usr/bin/python3 /home/pi/pos_terminal.py >> /home/pi/pos.log 2>&1
```

The `sleep 15` gives the I2C/SPI buses time to come up before the script grabs
them. Reboot to confirm:

```bash
sudo reboot
```

Check `/home/pi/pos.log` if anything looks off.

---

## 8. Day-of usage

1. Plug the Pi into the power bank via the inline-switch cable.
2. Flick the switch on about 2 minutes before you need it. That covers boot plus
   the cron `sleep`.
3. When the OLED shows **TAP CARD TO PAY**, you're live.
4. Tap any 13.56 MHz card or fob against the front panel. The device beeps,
   plays the "contacting bank" animation, then shows **APPROVED**.
5. It returns to idle automatically, with no buttons and no operator. Tap again
   to repeat.

That's it. No internet, no real transaction, just very convincing theatre.