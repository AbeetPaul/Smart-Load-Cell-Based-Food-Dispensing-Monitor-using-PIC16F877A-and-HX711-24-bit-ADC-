PROCESSOR 16F877A
#include <xc.inc>

;------------------------------------------------------------
; Configuration Bits (XC8 pic-as syntax)
;------------------------------------------------------------
config FOSC = XT
config WDTE = OFF
config PWRTE = ON
config BOREN = ON
config LVP = OFF
config CPD = OFF
config WRT = OFF
config CP = OFF

;------------------------------------------------------------
; RAM Variables (Udata section for pic-as)
;------------------------------------------------------------
PSECT udata_bank0, class=BANK0, space=1
DATA_H:     DS 1    ; MSB
DATA_M:     DS 1    ; MID
DATA_L:     DS 1    ; LSB
BIT_COUNT:  DS 1    ; loop counter
TEMP_BYTE:  DS 1    ; scratch
DELAY_CNT:  DS 1    ; delay counter

;------------------------------------------------------------
; Reset Vector
;------------------------------------------------------------
PSECT resetVec, class=CODE, delta=2
resetVec:
    GOTO    MAIN

;------------------------------------------------------------
; Main Code Section
;------------------------------------------------------------
PSECT code
MAIN:
    ;--- Configure PORTB ---
    BANKSEL TRISB       ; Bank 1
    MOVLW   0x01        ; RB0=Input(DOUT), RB1=Output(SCK)
    MOVWF   TRISB
    CLRF    TRISC       ; PORTC all output
    
    BANKSEL PORTB       ; Back to Bank 0
    CLRF    PORTB
    CLRF    PORTC
    BCF     PORTB, 1    ; Ensure SCK (RB1) starts LOW

MAIN_LOOP:
    CALL    HX711_READ
    
    MOVF    DATA_L, W
    MOVWF   PORTC       ; Output LSB to PORTC
    
    CALL    DELAY_500MS
    GOTO    MAIN_LOOP

;************************************************************
; SUBROUTINES
;************************************************************
HX711_READ:
WAIT_DRDY:
    BTFSC   PORTB, 0    ; DOUT (RB0) = 0 means data ready
    GOTO    WAIT_DRDY

    ; Read 3 Bytes
    MOVLW   8
    MOVWF   BIT_COUNT
    CALL    READ_BYTE
    MOVWF   DATA_H

    MOVLW   8
    MOVWF   BIT_COUNT
    CALL    READ_BYTE
    MOVWF   DATA_M

    MOVLW   8
    MOVWF   BIT_COUNT
    CALL    READ_BYTE
    MOVWF   DATA_L

    ; 25th pulse for Gain 128
    BSF     PORTB, 1    ; SCK HIGH
    NOP
    BCF     PORTB, 1    ; SCK LOW
    RETURN

READ_BYTE:
    CLRF    TEMP_BYTE
READ_NEXT_BIT:
    BSF     PORTB, 1    ; SCK HIGH
    NOP
    
    BCF     STATUS, 0   ; Clear Carry (C is bit 0 in STATUS)
    BTFSC   PORTB, 0    ; Sample DOUT
    BSF     STATUS, 0   ; Set Carry if DOUT=1
    
    RLF     TEMP_BYTE, F 
    BCF     PORTB, 1    ; SCK LOW
    
    DECFSZ  BIT_COUNT, F
    GOTO    READ_NEXT_BIT
    MOVF    TEMP_BYTE, W
    RETURN

DELAY_500MS:
    MOVLW   200
    MOVWF   DELAY_CNT
DELAY_OUTER:
    MOVLW   250
    MOVWF   BIT_COUNT
DELAY_INNER:
    NOP
    NOP
    DECFSZ  BIT_COUNT, F
    GOTO    DELAY_INNER
    DECFSZ  DELAY_CNT, F
    GOTO    DELAY_OUTER
    RETURN

END resetVec