# Smart Food Dispensing Monitor: PIC16F877A + HX711

A custom KiCad-designed PCB for precise weight measurement in food dispensing management. The board pairs a PIC16F877A microcontroller with the HX711 24-bit ADC to acquire load cell data using assembly firmware.

## Repository Structure

```
/fabrication    → Primary manufacturing files (e.g., 1st.kicad_sch)
/documentation  → High-resolution PCB layouts and circuit schematics
/firmware       → Assembly source (.asm) and compiled .HEX file
```

## Hardware Architecture

The system combines the versatile PIC family with the 24-bit precision needed for sensitive load cell data acquisition, a balanced and cost-effective solution.

| Component | Specification | Role |
|-----------|---------------|------|
| U1 | PIC16F877A-IP | Central processing unit; runs the assembly logic and manages data flow |
| U2 | HX711 | 24-bit ADC designed for load cell and bridge sensor interfacing |
| Y1 | 4 MHz Crystal | Primary clock source; gives a 1 µs instruction cycle (Fosc/4) |
| R1 | 10k Resistor | Pull-up on MCLR (Pin 1) to prevent accidental resets |
| C1, C2 | 22 pF Capacitors | Stabilize the crystal oscillator for clean clock generation |

### Pin Connections

| PIC16F877A | HX711 | Configuration |
|------------|-------|---------------|
| RB0 (Pin 33) | DOUT (Pin 12) | Input: detects data-ready and receives the serial bitstream |
| RB1 (Pin 34) | PD_SCK (Pin 11) | Output: drives the serial clock and power-down control |

## Firmware Logic

The firmware follows a four-stage communication protocol:

1. **Data-ready polling:** monitors the HX711 using `BTFSC` on `PORTB,0` and waits for DOUT to go low, signaling a completed conversion.
2. **24-bit retrieval:** performs three successive 8-bit reads into `DATA_H` (high), `DATA_M` (middle), and `DATA_L` (low) to rebuild the full 24-bit raw value.
3. **Gain selection:** after the 24th bit, applies a 25th clock pulse by toggling RB1 high then low, setting gain to 128 on Channel A for the next conversion.
4. **Output mapping:** sends `DATA_L` to PORTC (Pins 15-18 and 23-26) for external monitoring, debugging, or immediate processing.

### Timing Note

The 4 MHz oscillator gives a standard 1 µs instruction cycle. The current `DELAY_500MS` loop constants (200 and 250) produce an actual delay of about **250 ms**. If you need a strict 500 ms update rate, adjust these constants.

## Simulation and Deployment

The schematic and PCB layout were developed in KiCad EDA. Verifying the firmware in simulation before building hardware reduces the risk of failure.

### Virtual Simulation
1. Open Proteus or SimulIDE.
2. Load the compiled `.HEX` file from `/firmware` into the virtual PIC16F877A.
3. Monitor the bit-banging sequence on RB0 and RB1 to verify the communication logic and the gain selection pulse.

### Physical Programming
The PCB includes an **ICSP header (J1)**, so the PIC16F877A can be flashed directly on the board. This allows quick firmware updates and final calibration without removing the chip.

## Tech Stack

`PIC16F877A` · `HX711` · `KiCad` · `PIC Assembly` · `Proteus / SimulIDE`

# MindMap

<img width="3560" height="5636" alt="Mindmap" src="https://github.com/user-attachments/assets/f8a237ac-8446-4d8e-abdb-da1aa47589ea" />

