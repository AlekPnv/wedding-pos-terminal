#!/usr/bin/env python3
"""Fake POS terminal for a Pi Zero WH.

SSD1306 OLED over I2C, RC522 RFID over SPI. Tap a card and it runs a
"contacting bank" animation, then approves. Nothing is actually charged.
"""
import time

import RPi.GPIO as GPIO
from luma.core.interface.serial import i2c
from luma.oled.device import ssd1306
from luma.core.render import canvas
from PIL import ImageFont
from mfrc522 import SimpleMFRC522

# Config
AMOUNT = "10,000.00"
CURRENCY = "EUR"
APPROVED_LINE1 = "Congratulations!"
APPROVED_LINE2 = "Enjoy the show ;)"
PROCESSING_SECS = 4
BUZZER_PIN = 17

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)
GPIO.setup(BUZZER_PIN, GPIO.OUT, initial=GPIO.LOW)

serial_bus = i2c(port=1, address=0x3C)  # default addr for these boards
device = ssd1306(serial_bus)
reader = SimpleMFRC522()

try:
    FONT_BIG = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 16)
    FONT_MED = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 12)
    FONT_SML = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 10)
except OSError:
    FONT_BIG = FONT_MED = FONT_SML = ImageFont.load_default()


def _beep(duration):
    GPIO.output(BUZZER_PIN, GPIO.HIGH)
    time.sleep(duration)
    GPIO.output(BUZZER_PIN, GPIO.LOW)


def beep_card():
    _beep(0.05)


def beep_approve():
    for dur in [0.06, 0.06, 0.22]:
        _beep(dur)
        time.sleep(0.05)


def screen_splash():
    with canvas(device) as draw:
        draw.rectangle(device.bounding_box, outline="white")
        draw.text((22, 5), "POS TERMINAL", font=FONT_BIG, fill="white")
        draw.text((34, 26), "Est. Today", font=FONT_SML, fill="white")
        draw.text((10, 40), "Initialising...", font=FONT_SML, fill="white")
    beep_card()
    time.sleep(0.1)
    beep_card()
    time.sleep(3)


def screen_idle():
    with canvas(device) as draw:
        draw.text((0, 0), f"DUE ({CURRENCY}):", font=FONT_SML, fill="white")
        draw.text((0, 12), AMOUNT, font=FONT_BIG, fill="white")
        draw.line([(0, 32), (128, 32)], fill="white")
        draw.text((6, 36), "TAP CARD TO PAY", font=FONT_SML, fill="white")
        draw.text((18, 50), ">>> Ready <<<", font=FONT_SML, fill="white")


def screen_card_detected():
    with canvas(device) as draw:
        draw.text((10, 10), "Card detected!", font=FONT_MED, fill="white")
        draw.text((10, 30), "Authorising...", font=FONT_MED, fill="white")
    beep_card()
    time.sleep(0.8)


def screen_processing(step, total):
    dots = "." * (step % 4)
    bar_fill = int((step / total) * 124)
    with canvas(device) as draw:
        draw.text((0, 2), "CONTACTING BANK...", font=FONT_SML, fill="white")
        draw.text((0, 16), f"Processing{dots:<3}", font=FONT_MED, fill="white")
        draw.rectangle([(0, 36), (127, 50)], outline="white")
        if bar_fill > 0:
            draw.rectangle([(2, 38), (2 + bar_fill, 48)], fill="white")
        draw.text((16, 53), "Please wait...", font=FONT_SML, fill="white")


def screen_approved():
    with canvas(device) as draw:
        draw.rectangle(device.bounding_box, outline="white")
        draw.text((10, 4), "** APPROVED **", font=FONT_MED, fill="white")
        draw.line([(0, 20), (128, 20)], fill="white")
        draw.text((2, 26), APPROVED_LINE1, font=FONT_SML, fill="white")
        draw.text((2, 40), APPROVED_LINE2, font=FONT_SML, fill="white")
        draw.text((2, 53), "Ref: POS-0001", font=FONT_SML, fill="white")
    beep_approve()
    time.sleep(8)


def main():
    print("POS terminal ready.")
    screen_splash()
    try:
        while True:
            screen_idle()
            # Poll the reader directly so we don't block on read()
            status, _ = reader.READER.MFRC522_Request(reader.READER.PICC_REQIDL)
            if status != reader.READER.MI_OK:
                time.sleep(0.1)
                continue

            screen_card_detected()
            total = int(PROCESSING_SECS / 0.25)
            for step in range(1, total + 1):
                screen_processing(step, total)
                time.sleep(0.25)
            screen_approved()
            time.sleep(1)
    except KeyboardInterrupt:
        print("\nShutting down.")
    finally:
        GPIO.cleanup()
        device.cleanup()
        print("Done.")


if __name__ == "__main__":
    main()
    