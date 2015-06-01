# VGA on DE0-Nano

The goal of this project was to create a VGA black box that can be
added to any project easily on the DE0-Nano. The only extra required hardware
is a VGA monitor. I developed using a 5" 800x480 display [available at Adafruit](http://www.adafruit.com/products/2110),
but anything should work as long as you have the timing information.

## Getting started

The project contains a sample application called vga_test, which renders a screen from
the code in framebuffer.v.

To use this project on your own, you'll need to add a vga_renderer module, and an appropriately
timed clock (the clock I used for the 5" display was 32.4MHz), along with providing an appropriate
framebuffer for your application, which could be driven from M9K or SDRAM or generated on the fly.

See the top of vga_renderer.v for wiring guidelines.

![VGA_Test demo](https://github.com/sarchar/vga_de0_nano/blob/master/vga_test.jpg)

## Clocks

The clock needs to match the pixel clock of your device.  For the 5" 800x480 device
running at 65Hz with the default timings, a clock of 32.4MHz is required.

## Features

Other features include:

* fb_hblank and fb_vblank flags go high when in V/H-blank
* 8-bit output for each color
* Configurable timing parameters

