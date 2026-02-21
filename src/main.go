package main

import (
	"fmt"
	"os"
)

func main() {
	// 1. Save cursor position and move to an impossibly large coordinate
	// \x1b[s  = Save cursor
	// \x1b[999;999H = Move to row 999, col 999
	// \x1b[6n = Query cursor position
	// \x1b[u  = Restore cursor
	fmt.Print("\x1b[s\x1b[999;999H\x1b[6n\x1b[u")

	// 2. Read the response from Stdin
	// The terminal responds with: \x1b[rows;colsR
	buf := make([]byte, 32)

	// Note: In a real app, you'd set the terminal to 'raw' mode
	// but that usually requires 'syscall'. For a simple script:
	n, _ := os.Stdin.Read(buf)

	fmt.Printf("\r\nResponse from terminal: %s\n", string(buf[:n]))
}
