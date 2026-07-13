# Bill of Materials

Everything needed to build one POS terminal. Prices are rough 2024–2025 street
prices in EUR — you'll pay the low end on AliExpress and the high end on Amazon
if you want it this week. Total lands around **€60–80** depending on what you
already have in a parts drawer.

| # | Component | Spec / Notes | Qty | ~Price (EUR) | Where |
|---|-----------|--------------|-----|--------------|-------|
| 1 | Raspberry Pi Zero WH | Zero W with pre-soldered 40-pin header | 1 | €15 | Amazon / Pi retailers |
| 2 | SSD1306 / SSD1315 OLED | 0.96", I2C, 128×64, monochrome | 1 | €3–5 | AliExpress / Amazon |
| 3 | RC522 RFID reader | 13.56 MHz, SPI interface, ships with header strip | 1 | €2–4 | AliExpress / Amazon |
| 4 | Active buzzer module | 3-pin, 3.3V/5V compatible (drive HIGH = sound) | 1 | €1–2 | AliExpress / Amazon |
| 5 | Tactile push buttons | 6mm, pack of 10 (decorative on the case) | 1 pk | €2 | AliExpress / Amazon |
| 6 | Jumper wires | Female-to-female, 20cm, assorted colours | 1 pk | €3 | AliExpress / Amazon |
| 7 | MicroSD card | 16–32 GB, Class 10 / A1 | 1 | €5–8 | Amazon |
| 8 | USB power bank | Any 5V, 10,000mAh+ for all-day runtime | 1 | €15–25 | Amazon |
| 9 | USB cable w/ inline switch | Micro-USB, with on/off toggle | 1 | €2–3 | AliExpress / Amazon |
| 10 | Aluminium heatsink kit | Stick-on, for the Pi Zero SoC | 1 | €2–3 | AliExpress / Amazon |
| 11 | RFID cards / fobs | 13.56 MHz Mifare, pack of 10 | 1 pk | €3–5 | AliExpress / Amazon |
| 12 | Black PLA filament | ~250g for the enclosure (or use what you have) | — | €5–8 | Amazon / local |

## Notes

- **The RC522 runs on 3.3V.** Do not feed it 5V — it will cook. See the wiring
  table in [../docs/setup.md](../docs/setup.md).
- **Any 13.56 MHz card works** for the tap — the script doesn't validate UIDs,
  it just detects a card in the field. Your building fob, a hotel key card, or
  the fobs above are all fine.
- The **inline-switch USB cable** is the difference between "power on discreetly
  under the table" and "fumble with a power bank button." Worth the €2.
- **Heatsink** is optional but cheap insurance for a device that idles in a
  closed plastic box.

## Tools used

- Soldering iron + solder (to fit the RC522 header strip)
- Wire cutters / strippers
- 3D printer (FDM) for the enclosure
- Small superglue for the button retainer discs
- MicroSD card reader (for flashing the OS)
