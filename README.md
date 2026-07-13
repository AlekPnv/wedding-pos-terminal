# Wedding POS Terminal

A fake payment terminal that demands an absurd sum before it'll approve anything. Built on a Raspberry Pi Zero WH, sealed in a 3D-printed case, runs off a pocket power bank.

The setup: before the groom could collect the bride, he had to tap a card and pay. The terminal beeps, shows a very official *CONTACTING BANK...* progress bar, thinks hard for a few seconds, then flashes PAYMENT APPROVED with a custom message. No money moves. No network needed. Just a self-contained prop that looks and sounds like the real thing.

<img src="images/build/15_finished.jpg" width="500" alt="The finished terminal">

---

## What it does

One loop, no operator required:

```
idle  →  tap card  →  "Card detected!"  →  processing animation  →  APPROVED  →  back to idle
```

On idle the OLED shows the amount due and *TAP CARD TO PAY*. Tap any 13.56 MHz card or fob and it beeps once, shows a fake authorising screen, then runs a *CONTACTING BANK...* animation with a filling progress bar for a few seconds. That's the part that sells it. Then it beeps approval (three rising tones) and shows APPROVED with your custom message before looping back, ready for the next mark.

The code detects card presence rather than matching a UID, so a hotel key card works as well as the bundled fobs.

---

## Hardware

| Part | Role |
|------|------|
| Raspberry Pi Zero WH | Runs the Python app headless |
| SSD1306 0.96" OLED (I2C) | The terminal display |
| RC522 RFID reader (SPI) | Card detection |
| Active buzzer | Sound effects |
| 3x tactile buttons | Decorative (on the case, not wired to any behavior) |
| USB power bank + inline-switch cable | All-day power, no wall outlet needed |

Full parts list with prices: [hardware/bom.md](hardware/bom.md).

---

## Wiring

Seven components share the 40-pin header across I2C, SPI, and GPIO. One thing not to get wrong: the RC522 is a 3.3V part. 5V will kill it.

Pin table is in [docs/setup.md](docs/setup.md); the visual version is [hardware/wiring_diagram.svg](hardware/wiring_diagram.svg).

<img src="images/build/11_wiring_pi_overview.jpg" width="500" alt="Wiring the Pi">

---

## The enclosure

The case is a parametric OpenSCAD design, printed in black PLA. Three separate parts, each exported to its own STL:

1. Main shell: front face with the OLED window, an engraved TAP CARD HERE zone with an NFC-style ripple symbol, three button holes, and a side USB slot.
2. Back lid: snap-in rear cover with a cutout for the power cable.
3. Button caps (x3): printed with different engraved labels.

Every dimension is a named variable at the top of the file, so the whole thing resizes cleanly if you swap a module or change wall thickness. Source: [hardware/pos_terminal_case.scad](hardware/pos_terminal_case.scad).

On the buttons: the caps are a design feature, not a mechanism. No return springs, so they don't actuate. The prank runs fully automatically anyway, so they only need to look the part. A small [retainer disc](hardware/button_retainer.scad) keeps each cap from falling through the front face.

<img src="images/build/14_pos_inside.jpg" width="500" alt="Inside the finished case">

---

## Software

Runs headless on Raspberry Pi OS Lite. Quick version:

1. Flash OS Lite, enable SSH and WiFi in the imager.
2. `raspi-config` to enable SPI and I2C.
3. `pip install luma.oled mfrc522 RPi.GPIO spidev`
4. Drop `pos_terminal.py` on the Pi, edit the config block.
5. Add a `@reboot` crontab entry for autostart.

Full walkthrough (flashing, headless config, wiring, autostart) in [docs/setup.md](docs/setup.md).

The only things to personalise are at the top of the script:

```python
AMOUNT          = "10,000.00"
CURRENCY        = "EUR"
APPROVED_LINE1  = "Congratulations!"
APPROVED_LINE2  = "Enjoy the show ;)"
PROCESSING_SECS = 4
```

---

## Build process

The project went from "wouldn't it be funny if..." to a working prop in a handful of evenings.

**Research and parts.** Figured out which display, reader, and buzzer would work with a Pi Zero, then ordered them.

<img src="images/product/rc522.jpg" width="400" alt="RC522 RFID reader">

**Soldering.** The RC522 ships with a loose header strip. Soldered it on so it could take jumper wires.

<img src="images/build/01_soldering_result.jpg" width="400" alt="Soldered RC522 header">

**Wiring.** Connected all seven components to the 40-pin header: OLED on I2C, RC522 on SPI, buzzer and buttons on GPIO. Tested each subsystem as I went.

<img src="images/build/02_midway_progress.jpg" width="400" alt="Midway wiring check">
<img src="images/build/13_working_test.jpg" width="400" alt="OLED and reader working on the bench">

**Modeling the case.** Designed the enclosure in OpenSCAD, measuring each module so the internal cavities actually fit.

**Printing.** FDM printed in black PLA, face-down, and iterated on the OLED window and button hole sizes until the tolerances were right.

**Assembly.** Everything folded into the shell: Pi, reader behind the TAP CARD zone, OLED in its window, buzzer, power bank cable out the bottom.

<img src="images/build/08_case_inside.jpg" width="400" alt="Case interior during assembly">

**Done.** Powered from a bank, booted, tapped a card: beep, animation, APPROVED.

<img src="images/build/15_finished.jpg" width="500" alt="Finished terminal">

---

## What I learned

- **I2C OLED rendering** with `luma.oled`: driving an SSD1306 frame-by-frame via its canvas context, laying out text and shapes within 128x64 pixels. Hit a real overflow bug where the amount string was ~137px wide on the 128px screen; fixed it by putting the amount on its own line.
- **SPI RFID** with `mfrc522`: bringing up the RC522 on the SPI bus and detecting card presence.
- **Non-blocking card detection.** `SimpleMFRC522.read()` blocks until a card arrives, which freezes the idle screen. The main loop instead polls the underlying reader with `MFRC522_Request(PICC_REQIDL)` and only advances when a card is actually in the field.
- **GPIO buzzer timing**: distinct beep patterns (tap vs. approval) from plain HIGH/LOW pulses.
- **Headless Pi setup**: imager pre-config, SSH, enabling SPI/I2C, and `@reboot` cron autostart. Learned the hard way that `rc.local` doesn't exist on Pi OS Bookworm.
- **Parametric OpenSCAD**: driving the whole enclosure from named variables and building an NFC ripple symbol from arc primitives.
- **FDM tolerances**: getting press-fit windows and button holes right after accounting for how the printer over-extrudes on small features.

---

## Repository structure

```
wedding-pos-terminal/
├── pos_terminal.py
├── README.md
├── LICENSE
├── docs/
│   └── setup.md
├── hardware/
│   ├── bom.md
│   ├── wiring_diagram.svg
│   ├── pos_terminal_case.scad
│   └── button_retainer.scad
└── images/
    ├── build/
    └── product/
```

---

## License

MIT. See [LICENSE](LICENSE). Do fun things with it.
