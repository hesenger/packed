package main

import (
	"fmt"
	"math"
	"os"
	"os/signal"
	"syscall"
)

// getBraille returns the Unicode character for a 2x4 grid of booleans
func getBraille(dots [8]bool) string {
	var r rune = 0x2800
	// Standard mapping for Braille bit positions
	if dots[0] {
		r += 0x01
	} // Top-left
	if dots[1] {
		r += 0x08
	} // Top-right
	if dots[2] {
		r += 0x02
	} // Mid-upper-left
	if dots[3] {
		r += 0x10
	} // Mid-upper-right
	if dots[4] {
		r += 0x04
	} // Mid-lower-left
	if dots[5] {
		r += 0x20
	} // Mid-lower-right
	if dots[6] {
		r += 0x40
	} // Bottom-left
	if dots[7] {
		r += 0x80
	} // Bottom-right
	return string(r)
}

func main() {
	// 1. Get terminal size (Simplest way without cgo or ioctl is 80x24 fallback)
	// For a real app, you'd use golang.org/x/term, but to keep it <3MB,
	// we'll use a fixed size or env vars.
	width, height := 80, 24

	// 2. Setup Signal handling for a clean exit
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-c
		fmt.Print("\033[0m\033[H\033[J") // Reset color and clear
		os.Exit(0)
	}()

	// 3. Clear Screen and Hide Cursor
	fmt.Print("\033[2J\033[?25l")

	// Blue background ANSI + White foreground
	fmt.Print("\033[44m\033[37m")

	// Render Loop (Simplified to one frame)
	centerX, centerY := float64(width), float64(height*2) // Braille is 2x4
	radius := 15.0

	for y := 0; y < height; y++ {
		fmt.Printf("\033[%d;1H", y+1) // Move cursor to start of line
		for x := 0; x < width; x++ {
			var dots [8]bool
			// Check each of the 8 sub-pixels in the 2x4 braille cell
			for dy := 0; dy < 4; dy++ {
				for dx := 0; dx < 2; dx++ {
					pixelX := float64(x*2 + dx)
					pixelY := float64(y*4 + dy)

					// Circle Equation: (x-h)^2 + (y-k)^2 = r^2
					dist := math.Sqrt(math.Pow(pixelX-centerX, 2) + math.Pow(pixelY-centerY, 2))
					if math.Abs(dist-radius) < 0.8 {
						dots[dy*2+dx] = true
					}
				}
			}
			fmt.Print(getBraille(dots))
		}
	}

	// Keep alive until Ctrl+C
	select {}
}
