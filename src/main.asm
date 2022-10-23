; TetrisGYM - A Tetris Practise ROM
;
; @author Kirjava
; @github kirjavascript/TetrisGYM
; @disassembly CelestialAmber/TetrisNESDisasm
; @information ejona86/taus

.include "charmap.asm"
.include "constants.asm"
.include "io.asm"
.include "ram.asm"

.setcpu "6502"

.segment    "PRG_chunk1": absolute

; incremented to reset MMC1 reg
initRam:

.include "boot.asm"

mainLoop:
        jsr branchOnGameMode
        cmp gameModeState
        bne @continue
        jsr updateAudioWaitForNmiAndResetOamStaging
@continue:
        jmp mainLoop

.include "nmi/nmi.asm"
.include "nmi/render.asm"

.include "highscores/util.asm" ; TODO: add other stuff
.include "util/check_region.asm"
.include "util/bytesprite.asm"
.include "util/strings.asm"
.include "util/math.asm"
.include "sprites/piece.asm"
.include "sprites/drawrect.asm"

.include "gamemode/branch.asm"
    ; -> playAndEnding
.include "gamemodestate/branch.asm"
    ; -> updatePlayer1
.include "playstate/branch.asm"

.include "data/orientation.asm"

; TODO: util with menuThrottle, strings, modeText, twoDigsToPPU etc
; tree -P "*.asm" src







loadSpriteIntoOamStaging:
        clc
        lda spriteIndexInOamContentLookup
        rol a
        tax
        lda oamContentLookup,x
        sta generalCounter
        inx
        lda oamContentLookup,x
        sta generalCounter2
        ldx oamStagingLength
        ldy #$00
@whileNotFF:
        lda (generalCounter),y
        cmp #$FF
        beq @ret
        clc
        adc spriteYOffset
        sta oamStaging,x
        inx
        iny
        lda (generalCounter),y
        sta oamStaging,x
        inx
        iny
        lda (generalCounter),y
        sta oamStaging,x
        inx
        iny
        lda (generalCounter),y
        clc
        adc spriteXOffset
        sta oamStaging,x
        inx
        iny
        lda #$04
        clc
        adc oamStagingLength
        sta oamStagingLength
        jmp @whileNotFF

@ret:   rts

oamContentLookup:
        .addr   sprite00LevelSelectCursor
        .addr   sprite01GameTypeCursor
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite06TPiece
        .addr   sprite07SPiece
        .addr   sprite08ZPiece
        .addr   sprite09JPiece
        .addr   sprite0ALPiece
        .addr   sprite0BOPiece
        .addr   sprite0CIPiece
        .addr   sprite0EHighScoreNameCursor
        .addr   sprite0EHighScoreNameCursor
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   sprite02Blank
        .addr   spriteDebugLevelEdit ; $16
        .addr   spriteStateSave; $17
        .addr   spriteStateLoad; $18
        .addr   sprite02Blank ; $19
        .addr   sprite02Blank ; $1A
        .addr   spriteSeedCursor ; $1B
        .addr   sprite02Blank
        .addr   spritePractiseTypeCursor ; $1D
        .addr   spriteHeartCursor ; $1E
        .addr   spriteHeart ; $1F
        .addr   spriteReady ; $20
        .addr   spriteCustomLevelCursor ; $21
        .addr   spriteIngameHeart ; $22
; Sprites are sets of 4 bytes in the OAM format, terminated by FF. byte0=y, byte1=tile, byte2=attrs, byte3=x
; YY AA II XX
sprite00LevelSelectCursor:
        .byte   $00,$FC,$20,$00,$00,$FC,$20,$08
        .byte   $08,$FC,$20,$00,$08,$FC,$20,$08
        .byte   $FF
sprite01GameTypeCursor:
        .byte   $00,$27,$00,$00,$00,$27,$40,$3A
        .byte   $FF
; Used as a sort of NOOP for cursors
sprite02Blank:
        .byte   $00,$FF,$00,$00,$FF
sprite06TPiece:
        .byte   $00,$7B,$02,$FC,$00,$7B,$02,$04
        .byte   $00,$7B,$02,$0C,$08,$7B,$02,$04
        .byte   $FF
sprite07SPiece:
        .byte   $00,$7D,$02,$04,$00,$7D,$02,$0C
        .byte   $08,$7D,$02,$FC,$08,$7D,$02,$04
        .byte   $FF
sprite08ZPiece:
        .byte   $00,$7C,$02,$FC,$00,$7C,$02,$04
        .byte   $08,$7C,$02,$04,$08,$7C,$02,$0C
        .byte   $FF
sprite09JPiece:
        .byte   $00,$7D,$02,$FC,$00,$7D,$02,$04
        .byte   $00,$7D,$02,$0C,$08,$7D,$02,$0C
        .byte   $FF
sprite0ALPiece:
        .byte   $00,$7C,$02,$FC,$00,$7C,$02,$04
        .byte   $00,$7C,$02,$0C,$08,$7C,$02,$FC
        .byte   $FF
sprite0BOPiece:
        .byte   $00,$7B,$02,$00,$00,$7B,$02,$08
        .byte   $08,$7B,$02,$00,$08,$7B,$02,$08
        .byte   $FF
sprite0CIPiece:
        .byte   $04,$7B,$02,$F8,$04,$7B,$02,$00
        .byte   $04,$7B,$02,$08,$04,$7B,$02,$10
        .byte   $FF
sprite0EHighScoreNameCursor:
        .byte   $00,$FD,$20,$00,$FF
spriteDebugLevelEdit:
        .byte   $00,'X',$00,$00
        .byte   $FF
spriteStateLoad:
        .byte   $00,'L',$03,$00,$00,'O',$03,$08
        .byte   $00,'A',$03,$10,$00,'D',$03,$18
        .byte   $00,'E',$03,$20,$00,'D',$03,$28
        .byte   $FF
spriteStateSave:
        .byte   $00,'S',$03,$00,$00,'A',$03,$08
        .byte   $00,'V',$03,$10,$00,'E',$03,$18
        .byte   $00,'D',$03,$20
        .byte   $FF
spriteSeedCursor:
        .byte   $00,$6B,$00,$00
        .byte   $FF
spritePractiseTypeCursor:
        .byte   $00,$27,$00,$00
        .byte   $FF
spriteHeartCursor:
        .byte   $00,$6c,$00,$00,$FF
spriteHeart:
        .byte   $00,$6e,$00,$00,$FF
spriteReady:
        .byte   $00,'R',$01,$00,$08,'E',$01,$00
        .byte   $10,'A',$01,$00,$18,'D',$01,$00
        .byte   $20,'Y',$01,$FF
        .byte   $FF
spriteCustomLevelCursor:
        .byte   $00,$6A,$00,$00,$21,$6A,$80,$00
        .byte   $FF
spriteIngameHeart:
        .byte   $00,$2c,$00,$00,$FF
isPositionValid:
        lda tetriminoY
        asl a
        sta generalCounter
        asl a
        asl a
        clc
        adc generalCounter
        adc tetriminoX
        sta generalCounter
        lda currentPiece
        asl a
        asl a
        sta generalCounter2
        asl a
        clc
        adc generalCounter2
        tax
        ldy #$00
        lda #$04
        sta generalCounter3
; Checks one square within the tetrimino
@checkSquare:
        lda orientationTable,x
        clc
        adc tetriminoY
        adc #$02

        cmp #$16
        bcs @invalid
        lda orientationTable,x
        asl a
        sta generalCounter4
        asl a
        asl a
        clc
        adc generalCounter4
        clc
        adc generalCounter
        sta positionValidTmp
        inx
        inx
        lda orientationTable,x
        clc
        adc positionValidTmp
        tay
        lda (playfieldAddr),y
        cmp #EMPTY_TILE
        bcc @invalid
        lda orientationTable,x
        clc
        adc tetriminoX
        cmp #$0A
        bcs @invalid
        inx
        dec generalCounter3
        bne @checkSquare
        lda #$00
        sta generalCounter
        rts

@invalid:
        lda #$FF
        sta generalCounter
        rts

multBy10Table:
        .byte   $00,$0A,$14,$1E,$28,$32,$3C,$46
        .byte   $50,$5A,$64,$6E,$78,$82,$8C,$96
        .byte   $A0,$AA,$B4,$BE
multBy32Table:
        .byte 0,32,64,96,128,160,192,224
multBy100Table:
        .byte $0, $64, $c8, $2c, $90
        .byte $f4, $58, $bc, $20, $84

scoreSetupPPU:
        lda #$21
        sta PPUADDR
        lda #$18
        sta PPUADDR
        rts
renderBCDScore:
        jsr scoreSetupPPU
renderBCDScoreData:
        lda score+2
        jsr twoDigsToPPU
        jmp renderLowScore
renderClassicScore:
        jsr scoreSetupPPU
        ldx score+3
        ldy score+2
        jsr renderClassicHighByte
renderLowScore:
        lda score+1
        jsr twoDigsToPPU
        lda score
        jsr twoDigsToPPU
        rts

renderLettersScore:
        jsr scoreSetupPPU
        ldx score+3
        ldy score+2
        jsr renderLettersHighByte
        jmp renderLowScore

renderScoreCap:
        lda score+3
        beq renderBCDScore
        jsr scoreSetupPPU
        lda #$99
        jsr twoDigsToPPU
        lda #$99
        jsr twoDigsToPPU
        lda #$99
        jsr twoDigsToPPU
        rts

renderSevenDigit:
        jsr scoreSetupPPU
        lda score+3
        and #$F
        sta PPUDATA
        jsr renderBCDScoreData
        rts

renderFloat:
        lda #$21
        sta PPUADDR
        lda #$39
        sta PPUADDR
        lda score+3
        cmp #$A
        bcc @notTen
        lda score+3
        jsr twoDigsToPPU
        jmp @hundredThousands
@notTen:
        lda #$FF
        sta PPUDATA
        lda score+3
        and #$F
        sta PPUDATA
@hundredThousands:

        lda #$21
        sta PPUADDR
        lda #$3c
        sta PPUADDR
        clc
        lda score+2
        and #$F0
        ror
        ror
        ror
        ror
        sta PPUDATA
        jsr renderBCDScore
        rts

renderLevelDash:
        lda #$22
        sta PPUADDR
        lda #$B8
        sta PPUADDR
        lda levelNumber
        jsr renderByteBCD
        lda #'-'
        sta PPUDATA
        rts

renderModernLines:
        ; 'lines-' tile queue
        ; could lazy render this to make it 'free'
        lda linesTileQueue
        beq @endLinesTileQueue
        cmp #$86
        beq @endLinesTileQueue
        lda #$20
        sta PPUADDR
        lda linesTileQueue
        and #$F
        sta tmpZ
        adc #$6C
        sta PPUADDR
        ldx tmpZ
        lda linesDash, x
        sta PPUDATA
        inc linesTileQueue
@endLinesTileQueue:

        lda outOfDateRenderFlags
        and #$01
        beq @doneRenderLines

        ; 'normal' line drawing
        lda linesBCDHigh
        cmp #$A
        bcs @extraLines
        lda #$20
        sta PPUADDR
        lda #$73
        sta PPUADDR
        lda lines+1
        sta PPUDATA
        lda lines
        jsr twoDigsToPPU
        jmp @doneRenderLines
@extraLines:
        lda #$20
        sta PPUADDR
        lda #$72
        sta PPUADDR
        lda linesBCDHigh
        jsr twoDigsToPPU
        lda lines
        jsr twoDigsToPPU
@doneRenderLines:
        rts

; X - score+3 Y = score+2

; h = (0|score/100000)
; offset = (0|h /16) << 4
; output = h - offset
renderClassicHighByte:
        stx tmpX
        sty tmpY

        cpx #0
        bne @startWrap
        lda tmpY ; score+2
        jsr twoDigsToPPU
        rts
@startWrap:

        jsr getScoreDiv100k

        and #$F0 ; /16 << 4
        sta tmpX
        sec
        lda tmpZ
        sbc tmpX

        sta PPUDATA

        lda tmpY ; score+2
        and #$F
        sta PPUDATA
        rts

getScoreDiv100k:
        lda tmpY ; score+2
        lsr
        lsr
        lsr
        lsr
        sta tmpZ

        clc
        lda tmpX ; score+3
        and #$F
        tax
        lda multBy10Table, x
        adc tmpZ
        sta tmpZ

        lda tmpX ; score+3
        lsr
        lsr
        lsr
        lsr
        tax
        lda multBy100Table, x
        adc tmpZ
        sta tmpZ ; (0|score/100000)
        rts

; X - score+3 Y = score+2
renderLettersHighByte:
        stx tmpX
        sty tmpY

        cpx #0
        bne @startWrap
        lda tmpY ; score+2
        jsr twoDigsToPPU
        rts
@startWrap:

        jsr getScoreDiv100k

        sec
@mod40:
        sbc #36 ; loop body is ~20 cycles for worst case?
        bcs @mod40
        adc #36

        sta PPUDATA

        lda tmpY ; score+2
        and #$F
        sta PPUDATA

        rts

linesDash:
        .byte $15, $12, $17, $E, $1C, $24

; addresses
vramPlayfieldRows:
        .word   $20C6,$20E6,$2106,$2126
        .word   $2146,$2166,$2186,$21A6
        .word   $21C6,$21E6,$2206,$2226
        .word   $2246,$2266,$2286,$22A6
        .word   $22C6,$22E6,$2306,$2326


renderByteBCDNoPad:
        ldx #1
        jmp renderByteBCDStart
renderByteBCD:
        ldx #$0
renderByteBCDStart:
        sta tmpZ
        cmp #200
        bcc @maybe100
        lda #2
        sta PPUDATA
        lda tmpZ
        sbc #200
        jmp @byte
@maybe100:
        cmp #100
        bcc @not100
        lda #1
        sta PPUDATA
        lda tmpZ
        sbc #100
        jmp @byte
@not100:
        cpx #0
        bne @main
        lda #$EF
        sta PPUDATA
@main:
        lda tmpZ
@byte:
        tax
        lda byteToBcdTable, x

twoDigsToPPU:
        sta generalCounter
        and #$F0
        lsr a
        lsr a
        lsr a
        lsr a
        sta PPUDATA
        lda generalCounter
        and #$0F
        sta PPUDATA
        rts

copyPlayfieldRowToVRAM:
        ldx vramRow
        cpx #$15
        bpl @ret
        lda multBy10Table,x
        tay
        txa
        asl a
        tax
        inx
        lda vramPlayfieldRows,x
        sta PPUADDR
        dex

        lda vramPlayfieldRows,x
        clc
        adc #$06
        sta PPUADDR
@copyRow:
        ldx #$0A
@copyByte:
        lda (playfieldAddr),y
        sta PPUDATA
        iny
        dex
        bne @copyByte
        inc vramRow
        lda vramRow
        cmp #$14
        bmi @ret
        lda #$20
        sta vramRow
@ret:   rts

updateLineClearingAnimation:
.if AUTO_WIN
        inc playState
        rts
.endif
        lda frameCounter
        and #$03
        bne @ret
        ; invisible mode show blocks intead of empty
        ldy #$FF
        lda practiseType
        cmp #MODE_INVISIBLE
        bne @notInvisible
        ldy #BLOCK_TILES
@notInvisible:
        sty tmp3

        lda #$00
        sta generalCounter3
@whileCounter3LessThan4:
        ldx generalCounter3
        lda completedRow,x
        beq @nextRow
        asl a
        tay
        lda vramPlayfieldRows,y
        sta generalCounter
        lda generalCounter
        clc
        adc #$06
        sta generalCounter

        iny
        lda vramPlayfieldRows,y
        sta generalCounter2
        sta PPUADDR
        ldx rowY
        lda leftColumns,x
        clc
        adc generalCounter
        sta PPUADDR
        lda tmp3 ; #$FF
        sta PPUDATA
        lda generalCounter2
        sta PPUADDR
        ldx rowY
        lda rightColumns,x
        clc
        adc generalCounter
        sta PPUADDR
        lda tmp3 ; #$FF
        sta PPUDATA
@nextRow:
        inc generalCounter3
        lda generalCounter3
        cmp #$04
        bne @whileCounter3LessThan4
        inc rowY
        lda rowY
        cmp #$05
        bmi @ret
        inc playState
@ret:   rts

leftColumns:
        .byte   $04,$03,$02,$01,$00
rightColumns:
        .byte   $05,$06,$07,$08,$09
; Set Background palette 2 and Sprite palette 2
updatePaletteForLevel:
        lda levelNumber
@mod10: cmp #$0A
        bmi @copyPalettes ; bcc fixes the colour bug
        sec
        sbc #$0A
        jmp @mod10

@copyPalettes:
        asl a
        asl a
        tax
        lda #$00
        sta generalCounter
@copyPalette:
        lda #$3F
        sta PPUADDR
        lda #$08
        clc
        adc generalCounter
        sta PPUADDR
        lda colorTable,x
        sta PPUDATA
        lda colorTable+1,x
        sta PPUDATA
        lda colorTable+1+1,x
        sta PPUDATA
        lda colorTable+1+1+1,x
        sta PPUDATA
        lda generalCounter
        clc
        adc #$10
        sta generalCounter
        cmp #$20
        bne @copyPalette
        rts

; 4 bytes per level (bg, fg, c3, c4)
colorTable:
        .dbyt   $0F30,$2112,$0F30,$291A,$0F30,$2414,$0F30,$2A12
        .dbyt   $0F30,$2B15,$0F30,$222B,$0F30,$0016,$0F30,$0513
        .dbyt   $0F30,$1612,$0F30,$2716,$60E6,$69A5,$69C9,$1430
        .dbyt   $04A9,$2085,$69E6,$89A5,$89C9,$1430,$04A9,$2085
        .dbyt   $8960,$A549,$C920,$3056,$A5BE,$C901,$F020,$A5A4
        .dbyt   $C900,$D00E,$E6A4,$A5B7,$85A5,$20EB,$9885,$A64C
        .dbyt   $EA98,$A5A5,$C5B7,$D036,$A5A4,$C91C,$D030,$A900
        .dbyt   $85A4,$8545,$8541,$A901,$8548,$A905,$8540,$A6BF
        .dbyt   $BD56,$9985,$4220,$6999,$A5BE,$C901,$F007,$A5A6
        .dbyt   $85BF,$4CE6,$9820,$EB98,$85BF,$A900,$854E,$60A5
        .dbyt   $C0C9,$05D0,$12A6,$D3E6,$D3BD,$00DF,$4A4A,$4A4A
        .dbyt   $2907,$AABD,$4E99,$6020,$0799,$60E6,$1AA5,$1718
        .dbyt   $651A,$2907,$C907,$F008,$AABD,$4E99,$C519,$D01C
        .dbyt   $A217,$A002,$2047,$ABA5,$1729,$0718,$6519,$C907
        .dbyt   $9006,$38E9,$074C,$2A99,$AABD,$4E99,$8519,$6000
        .dbyt   $0000,$0001,$0101,$0102,$0203,$0404,$0505,$0505

playState_spawnNextTetrimino:
        lda vramRow
        cmp #$20
        bmi @ret

.if PRACTISE_MODE
        lda spawnDelay
        beq @notDelaying
        dec spawnDelay
        jmp @ret
.endif

@notDelaying:
        lda #$01
        sta playState

.if PRACTISE_MODE
        ; savestate patch
        lda saveStateDirty
        beq @noSaveState
        lda #0
        sta saveStateDirty
        rts
@noSaveState:
.endif

        jsr hzStart
        lda #$00
        sta fallTimer
        sta tetriminoY
        lda #$05
        sta tetriminoX
        ldx nextPiece
        lda spawnOrientationFromOrientation,x
        sta currentPiece
        jsr incrementPieceStat
        jsr chooseNextTetrimino
        sta nextPiece
@resetDownHold:
        lda #$00
        sta autorepeatY
@ret:   rts

chooseNextTetrimino:
        jmp pickTetriminoPre

pickRandomTetrimino:
        inc spawnCount
        lda rng_seed
        clc
        adc spawnCount
        and #$07
        cmp #$07
        beq @invalidIndex
        tax
        lda spawnTable,x
        cmp spawnID
        bne useNewSpawnID
@invalidIndex:
        ldx #rng_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        lda rng_seed
        and #$07
        clc
        adc spawnID
L992A:  cmp #$07
        bcc L9934
        sec
        sbc #$07
        jmp L992A

L9934:  tax
        lda spawnTable,x
useNewSpawnID:
        sta spawnID
        jsr pickTetriminoPost
        rts

pickTetriminoPre:
        lda practiseType
        cmp #MODE_TSPINS
        beq pickTetriminoT
        lda practiseType
        cmp #MODE_SEED
        beq pickTetriminoSeed
        lda practiseType
        cmp #MODE_TAPQTY
        beq pickTetriminoLongbar
        lda practiseType
        cmp #MODE_TAP
        beq pickTetriminoLongbar
        lda practiseType
        cmp #MODE_PRESETS
        beq pickTetriminoPreset
        jmp pickRandomTetrimino

pickTetriminoT:
        lda #$2
        sta spawnID
        rts

pickTetriminoLongbar:
        lda #$12
        sta spawnID
        rts

pickTetriminoSeed:
        jsr setSeedNextRNG

        ; SPSv3

        lda set_seed_input+2
        ror
        ror
        ror
        ror
        and #$F
        ; v3
        cmp #0
        bne @notZero
        lda #$10
@notZero:
        ; v2
        ; cmp #0
        ; beq @compatMode

        adc #1
        sta tmp3 ; step + 1 in tmp3
@loop:
        jsr setSeedNextRNG
        dec tmp3
        lda tmp3
        bne @loop
@compatMode:

        inc set_seed+2 ; 'spawnCount'
        lda set_seed
        clc
        adc set_seed+2
        and #$07
        cmp #$07
        beq @invalidIndex
        tax
        lda spawnTable,x
        cmp spawnID
        bne @useNewSpawnID
@invalidIndex:
        ldx #set_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        lda set_seed
        and #$07
        clc
        adc spawnID
@L992A:
        cmp #$07
        bcc @L9934
        sec
        sbc #$07
        jmp @L992A

@L9934:
        tax
        lda spawnTable,x
@useNewSpawnID:
        sta spawnID
        rts

setSeedNextRNG:
        ldx #set_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        rts

pickTetriminoPreset:
presetBitmask := tmp2
@start:
        inc presetIndex
        lda presetIndex
        and #$07
        cmp #$07
        beq pickTetriminoPreset
        sta presetIndex
        tax ; RNG in x
        ; store piece bitmask
        ldy presetModifier
        lda presets, y ; offset of preset in A
        tay
        lda presets, y
        sta presetBitmask
        ; create bit to compare with mask from RNG
        lda #1
@shiftBit:
        cpx #0
        beq @doneShifting
        asl
        dex
        jmp @shiftBit
@doneShifting:
        and presetBitmask
        bne @start
        ldx presetIndex ; restore RNG
        lda spawnTable,x
        sta spawnID
        rts

pickTetriminoPost:
        lda practiseType
        cmp #MODE_DROUGHT
        beq pickTetriminoDrought
        lda spawnID ; restore A
        rts

pickTetriminoDrought:
        lda spawnID ; restore A
        cmp #$12
        bne @droughtDone
        lda rng_seed+1
        and #$F
        adc #1 ; always adds 1 so code continues as normal if droughtModifier is 0
        cmp droughtModifier
        bmi @pickRando
        lda spawnID ; restore A
@droughtDone:
        rts
@pickRando:
        jmp pickRandomTetrimino

tetriminoTypeFromOrientation:
        .byte   $00,$00,$00,$00,$01,$01,$01,$01
        .byte   $02,$02,$03,$04,$04,$05,$05,$05
        .byte   $05,$06,$06
spawnTable:
        .byte   $02,$07,$08,$0A,$0B,$0E,$12
        .byte   $02
spawnOrientationFromOrientation:
        .byte   $02,$02,$02,$02,$07,$07,$07,$07
        .byte   $08,$08,$0A,$0B,$0B,$0E,$0E,$0E
        .byte   $0E,$12,$12
incrementPieceStat:
        tax
        lda tetriminoTypeFromOrientation,x
        asl a
        tax
        lda statsByType,x
        clc
        adc #$01
        sta generalCounter
        and #$0F
        cmp #$0A
        bmi L9996
        lda generalCounter
        clc
        adc #$06
        sta generalCounter
        cmp #$A0
        bcc L9996
        clc
        adc #$60
        sta generalCounter
        lda statsByType+1,x
        clc
        adc #$01
        sta statsByType+1,x
L9996:  lda generalCounter
        sta statsByType,x
        lda outOfDateRenderFlags
        ora #$40
        sta outOfDateRenderFlags
        rts

playState_lockTetrimino:
        jsr isPositionValid
        beq @notGameOver
; gameOver:
        lda #$02
        sta soundEffectSlot0Init
        lda #$0A ; playState_checkStartGameOver
        sta playState
        lda #$F0
        sta curtainRow
        jsr updateAudio2

        ; reset checkerboard score
        lda practiseType
        cmp #MODE_CHECKERBOARD
        bne @noChecker
        lda #0
        sta binScore
        sta binScore+1
        jsr setupScoreForRender
@noChecker:

        ; make invisible tiles visible
        lda #$00
        sta vramRow
        ldx #$C8
        lda #BLOCK_TILES+3
@invizLoop:
        jsr @makeVisible
        dex
        bne @invizLoop
        jsr @makeVisible
        rts

@makeVisible:
        ldy playfield, x
        cpy #INVISIBLE_TILE
        bne @emptyTile
        sta playfield, x
@emptyTile:
        rts

@notGameOver:
        lda vramRow
        cmp #$20
        bmi @ret
        lda tetriminoY
        asl a
        sta generalCounter
        asl a
        asl a
        clc
        adc generalCounter
        adc tetriminoX
        sta generalCounter
        lda currentPiece
        sta currentPiece_copy
        asl a
        asl a
        sta generalCounter2
        asl a
        clc
        adc generalCounter2
        tax
        ldy #$00
        lda #$04
        sta generalCounter3
; Copies a single square of the tetrimino to the playfield
@lockSquare:
        lda orientationTable,x
        asl a
        sta generalCounter4
        asl a
        asl a
        clc
        adc generalCounter4
        clc
        adc generalCounter
        sta positionValidTmp
        inx
        lda orientationTable,x
        sta generalCounter5
        lda linecapState
        cmp #LINECAP_INVISIBLE
        beq @inviz
        lda practiseType
        cmp #MODE_INVISIBLE
        bne @notInvisible
@inviz:
        lda #INVISIBLE_TILE
        sta generalCounter5
@notInvisible:
        inx
        lda orientationTable,x
        clc
        adc positionValidTmp
        tay
        lda generalCounter5
        ; BLOCK_TILES
        sta (playfieldAddr),y
        inx
        dec generalCounter3
        bne @lockSquare
        lda #$00
        sta lineIndex
        jsr updatePlayfield
        jsr updateMusicSpeed
        inc playState
@ret:   rts

playState_checkStartGameOver:
        ; skip curtain / rocket when not qualling
        lda qualFlag
        beq @checkForStartButton

        lda curtainRow
        cmp #$14
        beq @curtainFinished
        lda frameCounter
        and #$03
        bne @ret
        ldx curtainRow
        bmi @incrementCurtainRow
        lda multBy10Table,x
        tay
        lda #$00
        sta generalCounter3
        lda #$13
        sta currentPiece
@drawCurtainRow:
        lda #$4F
        sta (playfieldAddr),y
        iny
        inc generalCounter3
        lda generalCounter3
        cmp #$0A
        bne @drawCurtainRow
        lda curtainRow
        sta vramRow
@incrementCurtainRow:
        inc curtainRow
@ret:   rts

@curtainFinished:
        lda score+3
        bne @over30kormaxedout
        lda score+2
        cmp #$03
        bcc @checkForStartButton
@over30kormaxedout:

        lda #$80
        ldx palFlag
        cpx #0
        beq @notPAL
        lda #$66
@notPAL:
        jsr sleep_gameplay
        jsr endingAnimation

        jmp @exitGame

@checkForStartButton:
        lda newlyPressedButtons_player1
        cmp #$10
        bne @ret2
@exitGame:
        lda #$00
        sta playState
        sta newlyPressedButtons_player1
@ret2:  rts

sleep_gameplay:
        sta sleepCounter
@loop:  jsr updateAudioWaitForNmiAndResetOamStaging
        lda sleepCounter
        bne @loop
        rts

endingAnimation: ; rocket_screen
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
.if INES_MAPPER = 1
        lda #$02
        jsr changeCHRBank0
        lda #$02
        jsr changeCHRBank1
.elseif INES_MAPPER = 3
CNROM_CHR_ROCKET:
        lda #0
        sta CNROM_CHR_ROCKET+1
.endif
        jsr copyRleNametableToPpu
        .addr rocket_nametable
        jsr bulkCopyToPpu
        .addr rocket_palette

        ; lines
        lda #$21
        sta PPUADDR
        lda #$98
        sta PPUADDR
        lda lines+1
        sta PPUDATA
        lda lines
        jsr twoDigsToPPU

        ; score
        lda #$21
        sta PPUADDR
        lda #$18
        sta PPUADDR

        lda score+3
        beq @scoreEnd
        cmp #$A
        bmi @scoreHighWrite
        jsr twoDigsToPPU
        jmp @scoreEnd
@scoreHighWrite:
        sta PPUDATA
@scoreEnd:
        jsr renderBCDScoreData

        ; level
        lda #$22
        sta PPUADDR
        lda #$98
        sta PPUADDR
        lda startLevel
        jsr renderByteBCDNoPad
        lda #$22
        sta PPUADDR
        lda #$18
        sta PPUADDR
        lda levelNumber
        jsr renderByteBCDNoPad

        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
.if INES_MAPPER <> 3
        jsr updateAudioWaitForNmiAndResetOamStaging
.endif

        lda #0
        sta screenStage
        lda #$5
        sta renderMode
        lda #$1
        sta endingSleepCounter
        lda #$80 ; timed in bizhawk tasstudio to be 1 frame longer than usual
        sta endingSleepCounter+1

endingLoop:
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr handleRocket

        lda screenStage
        bne @waitEnd

        ; rocket counter
        lda endingSleepCounter+1
        bne @notZero
        lda endingSleepCounter
        beq @counterEnd
        dec endingSleepCounter
@notZero:
        dec endingSleepCounter+1
        jmp endingLoop

@counterEnd:
        lda #1
        sta screenStage
        lda #0
        sta endingRocketCounter
@waitEnd:
        lda newlyPressedButtons_player1
        cmp #$10
        bne endingLoop
        rts

handleRocket:
        ; controls
        lda heldButtons_player1
        and #BUTTON_UP
        beq @notPressedUp
        dec endingRocketY
@notPressedUp:
        lda heldButtons_player1
        and #BUTTON_DOWN
        beq @notPressedDown
        inc endingRocketY
@notPressedDown:
        lda heldButtons_player1
        and #BUTTON_LEFT
        beq @notPressedLeft
        dec endingRocketX
@notPressedLeft:
        lda heldButtons_player1
        and #BUTTON_RIGHT
        beq @notPressedRight
        inc endingRocketX
@notPressedRight:

        ; render
        lda endingRocketCounter
        adc #2
        sta endingRocketCounter
        jsr sin_A
        txa
        cmp #$80 ; setup for ASR
        ror ; A / 2
        cmp #$80
        ror ; A / 4
        cmp #$80
        ror ; A / 8
        cmp #$80
        ror ; A / 16
        adc #$78
        adc endingRocketY

        ; draw cathedral
        sta spriteYOffset
        lda #$68
        adc endingRocketX
        sta spriteXOffset
        lda #<spriteCathedral
        sta $0
        lda #>spriteCathedral
        sta $1
        jsr loadRectIntoOamStaging

        lda #$3F
        adc spriteYOffset
        sta spriteYOffset
        lda #$78
        adc endingRocketX
        sta spriteXOffset
        lda #<spriteCathedralFire0
        sta $0
        lda #>spriteCathedralFire0
        sta $1
        lda frameCounter
        and #1
        beq @otherFrame
        lda #<spriteCathedralFire1
        sta $0
        lda #>spriteCathedralFire1
        sta $1
@otherFrame:
        jsr loadRectIntoOamStaging
        rts

playState_checkForCompletedRows:
        lda vramRow
        cmp #$20
        bpl @updatePlayfieldComplete
        jmp playState_checkForCompletedRows_return

@updatePlayfieldComplete:

        lda tetriminoY
        sec
        sbc #$02
        bpl @yInRange
        lda #$00
@yInRange:
        clc
        adc lineIndex
        sta generalCounter2
        asl a
        sta generalCounter
        asl a
        asl a
        clc
        adc generalCounter
        sta generalCounter
        tay
        ldx #$0A

@checkIfRowComplete:
.if AUTO_WIN
        jmp @rowIsComplete
.endif
        lda practiseType
        cmp #MODE_TSPINS
        beq @rowNotComplete

        lda practiseType
        cmp #MODE_FLOOR
        beq @fullRowBurningCheck
        lda linecapState
        cmp #LINECAP_FLOOR
        beq @fullRowBurningCheck
        bne @normalRow

@fullRowBurningCheck:
        ; bugfix to ensure complete rows aren't cleared
        ; used in floor / linecap floor
        lda currentPiece_copy
        beq @IJLTedge
        cmp #5
        beq @IJLTedge
        cmp #$10
        beq @IJLTedge
        cmp #$12
        beq @IJLTedge
        bne @normalRow
@IJLTedge:
        lda lineIndex
        cmp #3
        bcs @rowNotComplete
@normalRow:


@checkIfRowCompleteLoopStart:
        lda (playfieldAddr),y
        cmp #EMPTY_TILE
        beq @rowNotComplete
        iny
        dex
        bne @checkIfRowCompleteLoopStart

@rowIsComplete:
        ; sound effect $A to slot 1 used to live here
        inc completedLines
        ldx lineIndex
        lda generalCounter2
        sta completedRow,x
        ldy generalCounter
        dey
@movePlayfieldDownOneRow:
        lda (playfieldAddr),y
        ldx #$0A
        stx playfieldAddr
        sta (playfieldAddr),y
        lda #$00
        sta playfieldAddr
        dey
        cpy #$FF
        bne @movePlayfieldDownOneRow
        lda #EMPTY_TILE
        ldy #$00
@clearRowTopRow:
        sta (playfieldAddr),y
        iny
        cpy #$0A
        bne @clearRowTopRow
        lda #$13
        sta currentPiece
        jmp @incrementLineIndex

@rowNotComplete:
        ldx lineIndex
        lda #$00
        sta completedRow,x
@incrementLineIndex:

        ; patch tapquantity data
        lda practiseType
        cmp #MODE_TAPQTY
        bne @tapQtyEnd
        lda completedLines
        cmp #0
        beq @tapQtyEnd
        ; mark as complete
        lda tqtyNext
        sta tqtyCurrent
        ; handle no burns
        lda tapqtyModifier
        and #$F0
        beq @tapQtyEnd
        lda #0
        sta vramRow
        inc playState
        inc playState
        lda #$07
        sta soundEffectSlot1Init
        rts
@tapQtyEnd:

        lda completedLines
        beq :+
        lda #$0A
        sta soundEffectSlot1Init
:

        inc lineIndex
        lda lineIndex
        cmp #$04 ; check actual height
        bmi playState_checkForCompletedRows_return

        lda #$00
        sta vramRow
        sta rowY
        lda completedLines
        cmp #$04
        bne @skipTetrisSoundEffect
        lda #$04
        sta soundEffectSlot1Init
@skipTetrisSoundEffect:
        inc playState
        lda completedLines
        bne playState_checkForCompletedRows_return
@skipLines:
playState_completeRowContinue:
        inc playState
        lda #$07
        sta soundEffectSlot1Init
playState_checkForCompletedRows_return:
        rts

playState_prepareNext:
        lda practiseType
        cmp #MODE_CHECKERBOARD
        bne @checkBType
        lda completedRow+3
        cmp #$13
        bne @endOfEndingCode
        jsr typeBEndingStuff
        rts

        ; bTypeGoalCheck
@checkBType:
        cmp #MODE_TYPEB
        bne @endOfEndingCode
        lda lines
        bne @endOfEndingCode

        jsr typeBEndingStuff

        ; patch levelNumber with score multiplier
        ldx levelNumber
        stx tmp3 ; and save a copy
        lda levelDisplayTable, x
        and #$F
        clc
        adc typeBModifier
        sta levelNumber
        beq @typeBScoreDone
        dec levelNumber

        ; patch some stuff
        lda #$5
        sta completedLines
        jsr addPointsRaw

        ; restore level
@typeBScoreDone:
        lda tmp3
        sta levelNumber

        rts
@endOfEndingCode:

        lda linecapState
        cmp #LINECAP_HALT
        bne @linecapHaltEnd
        lda #'G'
        sta playfield+$67
        sta playfield+$68
        lda #$28
        sta playfield+$6A
        lda #0
        sta vramRow
        jsr typeBEndingStuffEnd
        rts
@linecapHaltEnd:

        jsr practisePrepareNext
        inc playState
        rts

typeBEndingStuff:
        ; copy success graphic
        ldx #$5C
        ldy #$0
@copySuccessGraphic:
        lda typebSuccessGraphic,y
        cmp #$80
        beq @graphicCopied
        sta playfield,x
        inx
        iny
        jmp @copySuccessGraphic
@graphicCopied:
        lda #$00
        sta vramRow

typeBEndingStuffEnd:
        ; play sfx
        lda #$4
        sta soundEffectSlot1Init

        lda #$30
        jsr sleep_gameplay_nextSprite
        lda #$0A ; playState_checkStartGameOver
        sta playState
        rts

sleep_gameplay_nextSprite:
        sta sleepCounter
        jsr stageSpriteForNextPiece
@loop:  jsr updateAudioWaitForNmiAndResetOamStaging
        jsr stageSpriteForNextPiece
        lda sleepCounter
        bne @loop
        rts

typebSuccessGraphic:
        .byte   $17,$12,$0C,$0E,$FF,$28,$80

playState_receiveGarbage:
        ldy pendingGarbage
        beq @ret
        lda multBy10Table,y
        sta generalCounter2
        lda #$00
        sta generalCounter
@shiftPlayfieldUp:
        ldy generalCounter2
        lda (playfieldAddr),y
        ldy generalCounter
        sta (playfieldAddr),y
        inc generalCounter
        inc generalCounter2
        lda generalCounter2
        cmp #$C8
        bne @shiftPlayfieldUp
        iny

        ldx #$00
@fillGarbage:
        cpx garbageHole
        beq @hole
        lda #BLOCK_TILES + 3
        jmp @set
@hole:
        lda #EMPTY_TILE ; was $FF ?
@set:
        sta (playfieldAddr),y
        inx
        cpx #$0A
        bne @inc
        ldx #$00
@inc:   iny
        cpy #$C8
        bne @fillGarbage
        lda #$00
        sta pendingGarbage
        sta vramRow
@ret:  inc playState
@delay:  rts


garbageLines:
        .byte   $00,$00,$01,$02,$04
playState_updateLinesAndStatistics:
        jsr updateMusicSpeed
        lda completedLines
        bne @linesCleared
        jmp addPoints

@linesCleared:
        tax
        dex
        lda lineClearStatsByType,x
        clc
        adc #$01
        sta lineClearStatsByType,x
        and #$0F
        cmp #$0A
        bmi @noCarry
        lda lineClearStatsByType,x
        clc
        adc #$06
        sta lineClearStatsByType,x
@noCarry:
        lda outOfDateRenderFlags
        ora #$01
        sta outOfDateRenderFlags

; type-b lines decrement
        lda practiseType
        cmp #MODE_TYPEB
        bne @notTypeB
        lda completedLines
        sta generalCounter
        lda lines
        sec
        sbc generalCounter
        sta lines
        bpl @checkForBorrow
        lda #$00
        sta lines
        jmp addPoints
@checkForBorrow:
        and #$0F
        cmp #$0A
        bmi @addPoints_jmp
        lda lines
        sec
        sbc #$06
        sta lines
@addPoints_jmp:
        jmp addPoints
@notTypeB:

        ldx completedLines
incrementLines:
        inc lines
        lda lines
        and #$0F
        cmp #$0A
        bmi checkLevelUp
        lda lines
        clc
        adc #$06
        sta lines
        and #$F0
        cmp #$A0
        bcc checkLevelUp
        lda lines
        and #$0F
        sta lines
        inc lines+1

checkLevelUp:
        jsr calcBCDLinesAndTileQueue

        lda lines
        and #$0F
        bne @lineLoop

        lda practiseType
        cmp #MODE_TAPQTY
        beq @lineLoop
        cmp #MODE_TRANSITION
        bne @notSXTOKL
        lda transitionModifier
        cmp #$10
        bne @notSXTOKL
        jmp @nextLevel
@notSXTOKL:

        lda lines+1
        sta generalCounter2
        lda lines
        sta generalCounter
        lsr generalCounter2
        ror generalCounter
        lsr generalCounter2
        ror generalCounter
        lsr generalCounter2
        ror generalCounter
        lsr generalCounter2
        ror generalCounter
        lda levelNumber
        cmp generalCounter
        bpl @lineLoop

@nextLevel:
        inc levelNumber
        lda #$06 ; checked in floor linecap stuff, just below
        sta soundEffectSlot1Init
        lda outOfDateRenderFlags
        ora #$02
        sta outOfDateRenderFlags

@lineLoop:  dex
        bne incrementLines


checkLinecap: ; set linecapState
        ; check if enabled
        lda linecapFlag
        beq @linecapEnd
        ; skip check if already set
        lda linecapState
        bne @linecapEnd

        lda linecapWhen
        beq @linecapLevelCheck

;linecapLinesCheck

        lda lines+1
        cmp linecapLines+1
        bcc @linecapEnd
        lda lines
        cmp linecapLines
        bcc @linecapEnd
        bcs @linecapApply

@linecapLevelCheck:
        lda levelNumber
        cmp linecapLevel
        bcc @linecapEnd

@linecapApply:
        clc
        lda linecapHow
        adc #1
        sta linecapState

@linecapEnd:

        ; floor linecap effect
        lda linecapState
        cmp #LINECAP_FLOOR
        bne @floorLinecapEnd
        ; check level up sound is happening
        lda soundEffectSlot1Init
        cmp #6
        bne @floorLinecapEnd
        lda #$A
        sta garbageHole
        lda #1
        sta pendingGarbage
@floorLinecapEnd:

addPoints:
        inc playState
addPointsRaw:
.if NO_SCORING
        rts
.endif
        lda practiseType
        cmp #MODE_CHECKERBOARD
        beq handlePointsCheckerboard
        cmp #MODE_TAPQTY
        bne @notTapQuantity
        lda completedLines
        cmp #0
        bne @continueStreak
        jsr clearPoints
        lda outOfDateRenderFlags
        ora #$04
        sta outOfDateRenderFlags
        rts
@continueStreak:
        lda #4
        sta completedLines
@notTapQuantity:
        lda holdDownPoints
        cmp #$02
        bmi @noPushDown
        jsr addPushDownPoints
@noPushDown:
        lda #$0
        sta holdDownPoints
        jsr addLineClearPoints
        rts

handlePointsCheckerboard:
        lda score+1
        bne @handlePoints
        lda score+2
        beq @end
@handlePoints:
        ldx completedLines
        lda checkerboardPoints, x
        sta tmpZ
        sec
        lda binScore
        sbc tmpZ
        sta binScore
        lda binScore+1
        sbc #0
        sta binScore+1
        jsr setupScoreForRender
        lda outOfDateRenderFlags
        ora #$04
        sta outOfDateRenderFlags
@end:
        lda #$0
        sta completedLines
        lda #$0
        sta holdDownPoints
        rts

checkerboardPoints:
        .byte 0, 10, 20, 30, 40

ones := tmpX
hundredths := tmpY
low := tmpZ
high := tmp3

addPushDownPoints:
        clc
        lda score
        and #$F
        sta ones

        lda score
        jsr div16mul10
        adc ones
        sta hundredths

        lda holdDownPoints
        sbc #1
        adc ones
        sta holdDownPoints

        and #$F
        cmp #$A
        bcc @pdp2
        lda holdDownPoints
        adc #5
        sta holdDownPoints
@pdp2:

        lda holdDownPoints
        and #$f
        sta low

        lda holdDownPoints
        jsr div16mul10
        sta high

        lda hundredths
        sbc ones
        sec
        adc high
        sta holdDownPoints

        clc
        adc low
        cmp #101
        bcs @noLow
        sta holdDownPoints
@noLow:

        sec
        lda binScore
        sbc hundredths
        sta binScore
        lda binScore+1
        sbc #0
        sta binScore+1
        lda binScore+2
        sbc #0
        sta binScore+2
        lda binScore+3
        sbc #0
        sta binScore+3

        clc
        lda binScore
        adc holdDownPoints
        sta binScore
        lda binScore+1
        adc #0
        sta binScore+1
        lda binScore+2
        adc #0
        sta binScore+2
        lda binScore+3
        adc #0
        sta binScore+3
        rts

div16mul10:
        and #$f0
        ror
        ror
        ror
        ror
        tax
        lda multBy10Table,x
        rts

addLineClearPoints:
        lda #0
        sta factorA24+1
        sta factorA24+2
        lda levelNumber
        cmp #$FF
        bne @noverflow
        lda #1
        sta factorA24+1
        lda #0
        sta factorA24+0
        jmp @multSetupEnd
@noverflow:
        adc #1
        sta factorA24
@multSetupEnd:

        lda completedLines
        beq addLineClearPoints_end ; skip with 0 completed lines
        asl
        tax
        lda pointsTable, x
        sta factorB24+0
        lda pointsTable+1, x
        sta factorB24+1
        lda #0
        sta factorB24+2

        jsr unsigned_mul24 ; points to add in product24

        clc
        lda binScore
        adc product24
        sta binScore
        lda binScore+1
        adc product24+1
        sta binScore+1
        lda binScore+2
        adc product24+2
        sta binScore+2
        lda binScore+3
        adc #0
        sta binScore+3

addLineClearPoints_end:
        lda outOfDateRenderFlags
        ora #$04
        sta outOfDateRenderFlags
        lda #$00
        sta completedLines

setupScoreForRender:
        lda binScore
        sta binary32
        lda binScore+1
        sta binary32+1
        lda binScore+2
        sta binary32+2
        lda binScore+3
        sta binary32+3
        jsr BIN_BCD
        lda bcd32
        sta score
        lda bcd32+1
        sta score+1
        lda bcd32+2
        sta score+2
        lda bcd32+3
        sta score+3
        rts

clearPoints:
        lda #0
        sta score
        sta score+1
        sta score+2
        sta score+3
        sta binScore
        sta binScore+1
        sta binScore+2
        sta binScore+3
        rts

pointsTable:
        .word   0,40,100,300,1200
        .word   1000 ; used in btype score calc

calcBCDLinesAndTileQueue:
        lda #0
        sta tmp3
        lda lines+1
@modLoop:
        cmp #10
        bcc @modEnd
        sbc #10
        inc tmp3
        jmp @modLoop
@modEnd:
        sta linesBCDHigh

        lda tmp3
        rol
        rol
        rol
        rol
        adc linesBCDHigh
        sta linesBCDHigh

        ; setup tile queue
        lda linesBCDHigh
        cmp #$A
        bcc @ret
        lda linesTileQueue
        bne @ret
        lda #$80
        sta linesTileQueue
@ret:
        rts

updatePlayfield:
        ldx tetriminoY
        dex
        dex
        txa
        bpl @rowInRange
        lda #$00
@rowInRange:
        cmp vramRow
        bpl @ret
        sta vramRow
@ret:   rts

updateMusicSpeed:
        ldx #$05
        lda multBy10Table,x
        tay
        ldx #$0A
@checkForBlockInRow:
        lda (playfieldAddr),y
        cmp #EMPTY_TILE
        bne @foundBlockInRow
        iny
        dex
        bne @checkForBlockInRow
        lda allegro
        beq @ret
        lda #$00
        sta allegro
        ldx musicType
        lda musicSelectionTable,x
        jsr setMusicTrack
        jmp @ret

@foundBlockInRow:
        lda allegro
        bne @ret
        lda #$FF
        sta allegro
        lda musicType
        clc
        adc #$04
        tax
        lda musicSelectionTable,x
        jsr setMusicTrack
@ret:   rts

pollControllerButtons:
        ; lda gameMode
        ; cmp #$05
        ; beq @demoGameMode
        ; beq @recording
        jsr pollController
        rts

@demoGameMode:
        lda $D0
        cmp #$FF
        beq @recording
        jsr pollController
        lda newlyPressedButtons_player1
        cmp #$10
        beq @startButtonPressed
        lda demo_repeats
        beq @finishedMove
        dec demo_repeats
        jmp @moveInProgress

@finishedMove:
        ldx #$00
        lda (demoButtonsAddr,x)
        sta generalCounter
        jsr demoButtonsTable_indexIncr
        lda demo_heldButtons
        eor generalCounter
        and generalCounter
        sta newlyPressedButtons_player1
        lda generalCounter
        sta demo_heldButtons
        ldx #$00
        lda (demoButtonsAddr,x)
        sta demo_repeats
        jsr demoButtonsTable_indexIncr
        lda demoButtonsAddr+1
        cmp #>demoTetriminoTypeTable
        beq @ret
        jmp @holdButtons

@moveInProgress:
        lda #$00
        sta newlyPressedButtons_player1
@holdButtons:
        lda demo_heldButtons
        sta heldButtons_player1
@ret:   rts

@startButtonPressed:
        lda #>demoButtonsTable
        sta demoButtonsAddr+1
        lda #$00
        sta frameCounter+1
        lda #$01
        sta gameMode
        rts

@recording:
        jsr pollController
        lda gameMode
        cmp #$05
        bne @ret2
        ; lda $D0
        ; cmp #$FF
        bne @ret2
        lda heldButtons_player1
        cmp demo_heldButtons
        beq @buttonsNotChanged
        ldx #$00
        lda demo_heldButtons
        sta (demoButtonsAddr,x)
        jsr demoButtonsTable_indexIncr
        lda demo_repeats
        sta (demoButtonsAddr,x)
        jsr demoButtonsTable_indexIncr
        lda demoButtonsAddr+1
        cmp #>demoTetriminoTypeTable ; check movie has ended
        beq @ret2
        lda heldButtons_player1
        sta demo_heldButtons
        lda #$00
        sta demo_repeats
        rts

@buttonsNotChanged:
        inc demo_repeats

@ret2:  rts

demoButtonsTable_indexIncr:
        lda demoButtonsAddr
        clc
        adc #$01
        sta demoButtonsAddr
        lda #$00
        adc demoButtonsAddr+1
        sta demoButtonsAddr+1
        rts


; canon is adjustMusicSpeed
setMusicTrack:
.if !NO_MUSIC
        sta musicTrack
        lda gameMode
        cmp #$05
        bne @ret
        lda #$FF
        sta musicTrack
.endif
@ret:   rts



showHighScores:
        ldy #0
        lda #0
        sta generalCounter2
@copyEntry:
        lda generalCounter2
        asl a
        tax
        lda highScorePpuAddrTable,x
        sta PPUADDR
        inx
        lda highScorePpuAddrTable,x
        sta PPUADDR

        ; name
        ldx #highScoreNameLength
@copyChar:
        lda highscores,y
        sty generalCounter
        tay
        lda highScoreCharToTile,y
        ldy generalCounter
        sta PPUDATA
        iny
        dex
        bne @copyChar

        lda #$FF
        sta PPUDATA

        ; score
        lda highscores,y
        cmp #$A
        bmi @scoreHighWrite
        jsr twoDigsToPPU
        jmp @scoreEnd
@scoreHighWrite:
        sta PPUDATA
@scoreEnd:
        iny
        lda highscores,y
        jsr twoDigsToPPU
        iny
        lda highscores,y
        jsr twoDigsToPPU
        iny
        lda highscores,y
        jsr twoDigsToPPU
        iny

        lda #$FF
        sta PPUDATA

        ; lines
        lda highscores,y
        sta PPUDATA
        iny
        lda highscores,y
        jsr twoDigsToPPU
        iny

        lda #$FF
        sta PPUDATA

        ; levels
        lda highscores,y ; startlevel
        jsr renderByteBCD
        iny

        ; update PPUADDR for start level
        lda generalCounter2
        asl a
        tax
        lda highScorePpuAddrTable,x
        sta PPUADDR
        inx
        lda highScorePpuAddrTable,x
        adc #$35
        sta PPUADDR

        ; level
        lda highscores,y
        jsr renderByteBCD
        iny

        inc generalCounter2
        lda generalCounter2
        cmp #highScoreQuantity
        beq showHighScores_ret
        jmp @copyEntry

showHighScores_ret:  rts

highScorePpuAddrTable:
        .dbyt   $2284,$22C4,$2304
highScoreCharToTile:
        .byte   $FF,$0A,$0B,$0C,$0D,$0E,$0F,$10
        .byte   $11,$12,$13,$14,$15,$16,$17,$18
        .byte   $19,$1A,$1B,$1C,$1D,$1E,$1F,$20
        .byte   $21,$22,$23,$00,$01,$02,$03,$04
        .byte   $05,$06,$07,$08,$09,$25,$4F,$5E
        .byte   $5F,$6E,$6F,$52,$55,$24
highScoreCharSize := $2E
levelDisplayTable: ; original goes to 29
byteToBcdTable: ; original goes to 49
        .byte   $00,$01,$02,$03,$04,$05,$06,$07
        .byte   $08,$09,$10,$11,$12,$13,$14,$15
        .byte   $16,$17,$18,$19,$20,$21,$22,$23
        .byte   $24,$25,$26,$27,$28,$29,$30,$31
        .byte   $32,$33,$34,$35,$36,$37,$38,$39
        .byte   $40,$41,$42,$43,$44,$45,$46,$47
        .byte   $48,$49
        ; 50 extra bytes is shorter than a conversion routine (and super fast)
        ; (used in renderByteBCD)
        .byte   $50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$70,$71,$72,$73,$74,$75,$76,$77,$78,$79,$80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$90,$91,$92,$93,$94,$95,$96,$97,$98,$99

; Adjusts high score table and handles data entry, if necessary
handleHighScoreIfNecessary:
        ldy #0
        sty highScoreEntryRawPos
@compareWithPos:

        lda highscores+highScoreNameLength,y
        cmp score+3
        beq @checkHighByte
        bcs @tooSmall
        bcc adjustHighScores
@checkHighByte:
        lda highscores+highScoreNameLength +1,y
        cmp score+2
        beq @checkHundredsByte
        bcs @tooSmall
        bcc adjustHighScores
@checkHundredsByte:
        lda highscores+highScoreNameLength +2,y
        cmp score+1
        beq @checkOnesByte
        bcs @tooSmall
        bcc adjustHighScores
; This breaks ties by prefering the new score
@checkOnesByte:
        lda highscores+highScoreNameLength +3,y
        cmp score
        beq adjustHighScores
        bcc adjustHighScores
@tooSmall:

        tya
        clc
        adc #highScoreLength
        tay
        inc highScoreEntryRawPos
        lda highScoreEntryRawPos
        cmp #highScoreQuantity
        beq @ret
        jmp @compareWithPos

@ret:   rts

adjustHighScores:
        lda highScoreEntryRawPos
        cmp #$02
        bpl @doneMovingOldScores

        ldx #highScoreLength
        jsr copyHighscore

        lda highScoreEntryRawPos
        bne @doneMovingOldScores

        ldx #0
        jsr copyHighscore

@doneMovingOldScores:

        ldx highScoreEntryRawPos
        lda highScoreEntryRowOffsetLookup, x
        tax
        ldy #highScoreNameLength
        lda #$00
@clearNameLetter:
        sta highscores,x
        inx
        dey
        bne @clearNameLetter
        lda score+3
        sta highscores,x
        inx
        lda score+2
        sta highscores,x
        inx
        lda score+1
        sta highscores,x
        inx
        lda score
        sta highscores,x
        inx
        lda lines+1
        sta highscores,x
        inx
        lda lines
        sta highscores,x
        inx
        lda startLevel
        sta highscores,x
        inx
        lda levelNumber
        sta highscores,x
.if SAVE_HIGHSCORES
        jsr detectSRAM
        beq @noSRAM
        jsr copyScoresToSRAM
@noSRAM:
.endif
        jmp highScoreEntryScreen

copyHighscore:
        ldy #highScoreLength
@tmpHighScoreCopy:
        lda highscores,x
        sta highscores+highScoreLength,x
        inx
        dey
        bne @tmpHighScoreCopy
        rts

highScoreEntryScreen:
        RESET_MMC1
        lda #$10
        jsr setMMC1Control
        lda #$09
        jsr setMusicTrack
        lda #$02
        sta renderMode
        jsr updateAudioWaitForNmiAndDisablePpuRendering
        jsr disableNmi
        lda #$00
        jsr changeCHRBank0
        lda #$00
        jsr changeCHRBank1
.if INES_MAPPER = 3
        lda #%10000000
        sta PPUCTRL
        sta currentPpuCtrl
.endif
        jsr bulkCopyToPpu
        .addr   menu_palette
        jsr copyRleNametableToPpu
        .addr   enter_high_score_nametable
        jsr showHighScores
        lda #$21
        sta tmp1
        lda #$89
        sta tmp2
        jsr displayModeText
        lda #$02
        sta renderMode
        jsr waitForVBlankAndEnableNmi
        jsr updateAudioWaitForNmiAndResetOamStaging
        jsr updateAudioWaitForNmiAndEnablePpuRendering
        jsr updateAudioWaitForNmiAndResetOamStaging

        ldx highScoreEntryRawPos
        lda highScoreEntryRowOffsetLookup, x
        sta highScoreEntryNameOffsetForRow

        lda #$00
        sta highScoreEntryNameOffsetForLetter
        sta oamStaging
        lda highScoreEntryRawPos
        tax
        lda highScorePosToY,x
        sta spriteYOffset
@renderFrame:
        lda #$00
        sta oamStaging
        lda highScoreEntryNameOffsetForLetter
        asl
        asl
        asl
        adc #$20
        sta spriteXOffset
        lda #$0E
        sta spriteIndexInOamContentLookup
        lda frameCounter
        and #$03
        bne @flickerStateSelected_checkForStartPressed
        lda #$02
        sta spriteIndexInOamContentLookup
@flickerStateSelected_checkForStartPressed:
        jsr loadSpriteIntoOamStaging
        lda newlyPressedButtons_player1
        and #$10
        beq @checkForAOrRightPressed
        lda #$02
        sta soundEffectSlot1Init
        jmp @ret

@checkForAOrRightPressed:
        lda #BUTTON_RIGHT
        jsr menuThrottle
        bne @nextTile
        lda #BUTTON_A
        jsr menuThrottle
        beq @checkForBOrLeftPressed
@nextTile:
        lda #$01
        sta soundEffectSlot1Init
        inc highScoreEntryNameOffsetForLetter
        lda highScoreEntryNameOffsetForLetter
        cmp #highScoreNameLength
        bmi @checkForBOrLeftPressed
        lda #$00
        sta highScoreEntryNameOffsetForLetter
@checkForBOrLeftPressed:
        lda #BUTTON_LEFT
        jsr menuThrottle
        bne @prevTile
        lda #BUTTON_B
        jsr menuThrottle
        beq @checkForDownPressed
@prevTile:
        lda #$01
        sta soundEffectSlot1Init
        dec highScoreEntryNameOffsetForLetter
        lda highScoreEntryNameOffsetForLetter
        bpl @checkForDownPressed
        lda #highScoreNameLength-1
        sta highScoreEntryNameOffsetForLetter
@checkForDownPressed:
        lda #BUTTON_DOWN
        jsr menuThrottle
        beq @checkForUpPressed
        lda #$01
        sta soundEffectSlot1Init
        lda highScoreEntryNameOffsetForRow
        sta generalCounter
        clc
        adc highScoreEntryNameOffsetForLetter
        tax
        lda highscores,x
        sta generalCounter
        dec generalCounter
        lda generalCounter
        bpl @letterDoesNotUnderflow
        clc
        adc #highScoreCharSize
        sta generalCounter
@letterDoesNotUnderflow:
        lda generalCounter
        sta highscores,x
.if SAVE_HIGHSCORES
        tay
        jsr detectSRAM
        beq @noSRAMDown
        tya
        sta SRAM_highscores, x
@noSRAMDown:
.endif
@checkForUpPressed:
        lda #BUTTON_UP
        jsr menuThrottle
        beq @waitForVBlank
        lda #$01
        sta soundEffectSlot1Init
        lda highScoreEntryNameOffsetForRow
        sta generalCounter
        clc
        adc highScoreEntryNameOffsetForLetter
        tax
        lda highscores,x
        sta generalCounter
        inc generalCounter
        lda generalCounter
        cmp #highScoreCharSize
        bmi @letterDoesNotOverflow
        sec
        sbc #highScoreCharSize
        sta generalCounter
@letterDoesNotOverflow:
        lda generalCounter
        sta highscores,x
.if SAVE_HIGHSCORES
        tay
        jsr detectSRAM
        beq @noSRAMUp
        tya
        sta SRAM_highscores, x
@noSRAMUp:
.endif
@waitForVBlank:
        lda highScoreEntryNameOffsetForRow
        clc
        adc highScoreEntryNameOffsetForLetter
        tax
        lda highscores,x
        sta highScoreEntryCurrentLetter
        lda #$80
        sta outOfDateRenderFlags
        jsr updateAudioWaitForNmiAndResetOamStaging
        jmp @renderFrame

@ret:   jsr updateAudioWaitForNmiAndResetOamStaging
        rts

highScorePosToY:
        .byte   $9F,$AF,$BF
highScoreEntryRowOffsetLookup:
        .byte   $0, highScoreLength, highScoreLength*2


; canon is waitForVerticalBlankingInterval
updateAudioWaitForNmiAndResetOamStaging:
        jsr updateAudio_jmp
        lda #$00
        sta verticalBlankingInterval
        nop
@checkForNmi:
        lda verticalBlankingInterval
        beq @checkForNmi
        lda #$FF
        ldx #$02
        ldy #$02
        jsr memset_page
        rts

updateAudioAndWaitForNmi:
        jsr updateAudio_jmp
        lda #$00
        sta verticalBlankingInterval
        nop
@checkForNmi:
        lda verticalBlankingInterval
        beq @checkForNmi
        rts

updateAudioWaitForNmiAndDisablePpuRendering:
        jsr updateAudioAndWaitForNmi
        lda currentPpuMask
        and #$E1
_updatePpuMask:
        sta PPUMASK
        sta currentPpuMask
        rts

updateAudioWaitForNmiAndEnablePpuRendering:
        jsr updateAudioAndWaitForNmi
        jsr copyCurrentScrollAndCtrlToPPU
        lda currentPpuMask
        ora #$1E
        bne _updatePpuMask
waitForVBlankAndEnableNmi:
        lda PPUSTATUS
        and #$80
        bne waitForVBlankAndEnableNmi
        lda currentPpuCtrl
        ora #$80
        bne _updatePpuCtrl
disableNmi:
        lda currentPpuCtrl
        and #$7F
_updatePpuCtrl:
        sta PPUCTRL
        sta currentPpuCtrl
        rts

resetScroll:
        lda #0
        sta ppuScrollX
        sta PPUSCROLL
        sta ppuScrollY
        sta PPUSCROLL
        rts

copyCurrentScrollAndCtrlToPPU:
        lda ppuScrollX
        sta PPUSCROLL
        lda ppuScrollY
        sta PPUSCROLL
        lda currentPpuCtrl
        sta PPUCTRL
        rts

drawBlackBGPalette:
        lda #$3F
        sta PPUADDR
        lda #$0
        sta PPUADDR
        ldx #$10
@loadPaletteLoop:
        lda #$F
        sta PPUDATA
        dex
        bne @loadPaletteLoop
        rts

bulkCopyToPpu:
        jsr copyAddrAtReturnAddressToTmp_incrReturnAddrBy2
        jmp copyToPpu

LAA9E:  pha
        sta PPUADDR
        iny
        lda (tmp1),y
        sta PPUADDR
        iny
        lda (tmp1),y
        asl a
        pha
        lda currentPpuCtrl
        ora #$04
        bcs LAAB5
        and #$FB
LAAB5:  sta PPUCTRL
        sta currentPpuCtrl
        pla
        asl a
        php
        bcc LAAC2
        ora #$02
        iny
LAAC2:  plp
        clc
        bne LAAC7
        sec
LAAC7:  ror a
        lsr a
        tax
LAACA:  bcs LAACD
        iny
LAACD:  lda (tmp1),y
        sta PPUDATA
        dex
        bne LAACA
        pla
        cmp #$3F
        bne LAAE6
        sta PPUADDR
        stx PPUADDR
        stx PPUADDR
        stx PPUADDR
LAAE6:  sec
        tya
        adc tmp1
        sta tmp1
        lda #$00
        adc tmp2
        sta tmp2
; Address to read from stored in tmp1/2
copyToPpu:
        ldx PPUSTATUS
        ldy #$00
        lda (tmp1),y
        bpl LAAFC
        rts

LAAFC:  cmp #$60
        bne LAB0A
        pla
        sta tmp2
        pla
        sta tmp1
        ldy #$02
        bne LAAE6
LAB0A:  cmp #$4C
        bne LAA9E
        lda tmp1
        pha
        lda tmp2
        pha
        iny
        lda (tmp1),y
        tax
        iny
        lda (tmp1),y
        sta tmp2
        stx tmp1
        bcs copyToPpu
copyAddrAtReturnAddressToTmp_incrReturnAddrBy2:
        tsx
        lda stack+3,x
        sta tmpBulkCopyToPpuReturnAddr
        lda stack+4,x
        sta tmpBulkCopyToPpuReturnAddr+1
        ldy #$01
        lda (tmpBulkCopyToPpuReturnAddr),y
        sta tmp1
        iny
        lda (tmpBulkCopyToPpuReturnAddr),y
        sta tmp2
        clc
        lda #$02
        adc tmpBulkCopyToPpuReturnAddr
        sta stack+3,x
        lda #$00
        adc tmpBulkCopyToPpuReturnAddr+1
        sta stack+4,x
        rts

;reg x: zeropage addr of seed; reg y: size of seed
generateNextPseudorandomNumber:
        lda tmp1,x
        and #$02
        sta tmp1
        lda tmp2,x
        and #$02
        eor tmp1
        clc
        beq @updateNextByteInSeed
        sec
@updateNextByteInSeed:
        ror tmp1,x
        inx
        dey
        bne @updateNextByteInSeed
        rts

; canon is initializeOAM
copyOamStagingToOam:
        lda #$00
        sta OAMADDR
        lda #$02
        sta OAMDMA
        rts

pollController_actualRead:
        ldx joy1Location
        inx
        stx JOY1
        dex
        stx JOY1
        ldx #$08
@readNextBit:
        lda JOY1
        lsr a
        rol newlyPressedButtons_player1
        lsr a
        rol tmp1
        lda JOY2_APUFC
        lsr a
        rol newlyPressedButtons_player2
        lsr a
        rol tmp2
        dex
        bne @readNextBit
        rts

addExpansionPortInputAsControllerInput:
        lda tmp1
        ora newlyPressedButtons_player1
        sta newlyPressedButtons_player1
        lda tmp2
        ora newlyPressedButtons_player2
        sta newlyPressedButtons_player2
        rts

        jsr pollController_actualRead
        beq diffOldAndNewButtons
pollController:
        jsr pollController_actualRead
        jsr addExpansionPortInputAsControllerInput
        lda newlyPressedButtons_player1
        sta generalCounter2
        lda newlyPressedButtons_player2
        sta generalCounter3
        jsr pollController_actualRead
        jsr addExpansionPortInputAsControllerInput
        lda newlyPressedButtons_player1
        and generalCounter2
        sta newlyPressedButtons_player1
        lda newlyPressedButtons_player2
        and generalCounter3
        sta newlyPressedButtons_player2

        lda goofyFlag
        beq @noGoofy
        lda newlyPressedButtons_player1
        asl
        and #$AA
        sta tmp3
        lda newlyPressedButtons_player1
        and #$AA
        lsr
        ora tmp3
        sta newlyPressedButtons_player1
@noGoofy:

diffOldAndNewButtons:
        ldx #$01
@diffForPlayer:
        lda newlyPressedButtons_player1,x
        tay
        eor heldButtons_player1,x
        and newlyPressedButtons_player1,x
        sta newlyPressedButtons_player1,x
        sty heldButtons_player1,x
        dex
        bpl @diffForPlayer
        rts

; reg a: value; reg x: start page; reg y: end page (inclusive)
memset_page:
        pha
        txa
        sty tmp2
        clc
        sbc tmp2
        tax
        pla
        ldy #$00
        sty tmp1
@setByte:
        sta (tmp1),y
        dey
        bne @setByte
        dec tmp2
        inx
        bne @setByte
        rts

switch_s_plus_2a:
        asl a
        tay
        iny
        pla
        sta tmp1
        pla
        sta tmp2
        lda (tmp1),y
        tax
        iny
        lda (tmp1),y
        sta tmp2
        stx tmp1
        jmp (tmp1)

        sei
        RESET_MMC1
        lda #$1A
        jsr setMMC1Control
        rts

setMMC1Control:
.if INES_MAPPER = 1
        sta MMC1_Control
        lsr a
        sta MMC1_Control
        lsr a
        sta MMC1_Control
        lsr a
        sta MMC1_Control
        lsr a
        sta MMC1_Control
.endif
        rts

changeCHRBank0:
.if INES_MAPPER = 1
        sta MMC1_CHR0
        lsr a
        sta MMC1_CHR0
        lsr a
        sta MMC1_CHR0
        lsr a
        sta MMC1_CHR0
        lsr a
        sta MMC1_CHR0
.endif
        rts

changeCHRBank1:
.if INES_MAPPER = 1
        sta MMC1_CHR1
        lsr a
        sta MMC1_CHR1
        lsr a
        sta MMC1_CHR1
        lsr a
        sta MMC1_CHR1
        lsr a
        sta MMC1_CHR1
.endif
        rts

changePRGBank:
.if INES_MAPPER = 1
        sta MMC1_PRG
        lsr a
        sta MMC1_PRG
        lsr a
        sta MMC1_PRG
        lsr a
        sta MMC1_PRG
        lsr a
        sta MMC1_PRG
.endif
        rts

game_palette:
        .byte   $3F,$00,$20,$0F,$30,$12,$16,$0F
        .byte   $20,$12,$00,$0F,$2C,$16,$29,$0F
        .byte   $3C,$00,$30,$0F,$16,$2A,$22,$0F
        .byte   $10,$16,$2D,$0F,$2C,$16,$29,$0F
        .byte   $3C,$00,$30,$FF
title_palette:
        .byte   $3F,$00,$14,$0F,$3C,$38,$00,$0F
        .byte   $17,$27,$37,$0F,$30,MENU_HIGHLIGHT_COLOR,$00,$0F
        .byte   $22,$2A,$28,$0F,$30,$29,$27,$FF
menu_palette:
        .byte   $3F,$00,$16,$0F,$30,$38,$26,$0F
        .byte   $17,$27,$37,$0F,$30,MENU_HIGHLIGHT_COLOR,$00,$0F
        .byte   $16,$2A,$28,$0F,$16,$26,$27,$0f,$2A,$FF
rocket_palette:
        .byte   $3F,$11,$7,$16,$2A,$28,$0f,$37,$18,$38 ; sprite
        .byte   $3F,$00,$8,$0f,$3C,$38,$00,$0F,$20,$12,$15 ; bg
        .byte   $FF
wait_palette:
        .byte   $3F,$11,$1,$30
        .byte   $3F,$00,$8,$f,$30,$38,$26,$0F,$17,$27,$37
        .byte   $FF
game_type_menu_nametable: ; RLE
        .incbin "nametables/game_type_menu_nametable_practise.bin"
game_type_menu_nametable_extra: ; RLE
        .incbin "nametables/game_type_menu_nametable_extra.bin"
level_menu_nametable: ; RLE
        .incbin "nametables/level_menu_nametable_practise.bin"
game_nametable: ; RLE
        .incbin "nametables/game_nametable_practise.bin"
enter_high_score_nametable: ; RLE
        .incbin "nametables/enter_high_score_nametable_practise.bin"
rocket_nametable: ; RLE
        .incbin "nametables/rocket_nametable.bin"
legal_nametable: ; RLE
        .incbin "nametables/legal_nametable.bin"
speedtest_nametable: ; RLE
        .incbin "nametables/speedtest_nametable.bin"
title_nametable_patch: ; stripe
        .byte $21, $69, $5, $1D, $12, $1D, $15, $E
        .byte $FF
rocket_nametable_patch: ; stripe
        .byte $20, $83, 5, $19, $1B, $E, $1c, $1c
        .byte $20, $A3, 5, $1c, $1d, $a, $1b, $1d
        .byte $FF


.include "nametables/rle.asm"

.include "presets/presets.asm"

SLOT_SIZE := $100 ; ~$CC used, the rest free

; some repeated code here, dynamic 16 bit addressing is hard
; could replace it with code executed / modified in RAM

saveslots:
        .addr saveslot0
        .addr saveslot1
        .addr saveslot2
        .addr saveslot3
        .addr saveslot4
        .addr saveslot5
        .addr saveslot6
        .addr saveslot7
        .addr saveslot8
        .addr saveslot9
saveslot0:
        sta SRAM,y
        rts
saveslot1:
        sta SRAM+SLOT_SIZE,y
        rts
saveslot2:
        sta SRAM+(SLOT_SIZE*2),y
        rts
saveslot3:
        sta SRAM+(SLOT_SIZE*3),y
        rts
saveslot4:
        sta SRAM+(SLOT_SIZE*4),y
        rts
saveslot5:
        sta SRAM+(SLOT_SIZE*5),y
        rts
saveslot6:
        sta SRAM+(SLOT_SIZE*6),y
        rts
saveslot7:
        sta SRAM+(SLOT_SIZE*7),y
        rts
saveslot8:
        sta SRAM+(SLOT_SIZE*8),y
        rts
saveslot9:
        sta SRAM+(SLOT_SIZE*9),y
        rts

saveSlot:
        sta tmp3 ; save a copy of A
        lda saveStateSlot
        asl
        tax
        lda saveslots,x
        sta tmp1
        lda saveslots+1,x
        sta tmp1+1
        lda tmp3 ; restore it
        jmp (tmp1)

saveState:
        ldy #0
@copy:
        lda playfield,y
        jsr saveSlot
        iny
        cpy #$c8
        bcc @copy

        lda tetriminoX
        jsr saveSlot
        iny
        lda tetriminoY
        jsr saveSlot
        iny
        lda currentPiece
        jsr saveSlot
        iny
        lda nextPiece
        jsr saveSlot

        ; level/lines/score
        ; iny
        ; lda levelNumber
        ; jsr saveSlot
        ; iny
        ; lda lines
        ; jsr saveSlot
        ; iny
        ; lda score
        ; jsr saveSlot
        ; iny
        ; lda score+1
        ; jsr saveSlot
        ; iny
        ; lda score+2
        ; jsr saveSlot


        lda #$17
        sta saveStateSpriteType
        lda #$20
        sta saveStateSpriteDelay
        rts

loadslots:
        .addr loadslot0
        .addr loadslot1
        .addr loadslot2
        .addr loadslot3
        .addr loadslot4
        .addr loadslot5
        .addr loadslot6
        .addr loadslot7
        .addr loadslot8
        .addr loadslot9
loadslot0:
        lda SRAM,y
        rts
loadslot1:
        lda SRAM+SLOT_SIZE,y
        rts
loadslot2:
        lda SRAM+(SLOT_SIZE*2),y
        rts
loadslot3:
        lda SRAM+(SLOT_SIZE*3),y
        rts
loadslot4:
        lda SRAM+(SLOT_SIZE*4),y
        rts
loadslot5:
        lda SRAM+(SLOT_SIZE*5),y
        rts
loadslot6:
        lda SRAM+(SLOT_SIZE*6),y
        rts
loadslot7:
        lda SRAM+(SLOT_SIZE*7),y
        rts
loadslot8:
        lda SRAM+(SLOT_SIZE*8),y
        rts
loadslot9:
        lda SRAM+(SLOT_SIZE*9),y
        rts

loadSlot:
        lda saveStateSlot
        asl
        tax
        lda loadslots,x
        sta tmp1
        lda loadslots+1,x
        sta tmp1+1
        jmp (tmp1)

loadState:
        ldy #0
@copy:
        jsr loadSlot
        sta playfield,y
        iny
        cpy #$c8
        bcc @copy

        jsr loadSlot
        sta tetriminoX
        iny
        jsr loadSlot
        sta tetriminoY
        iny
        jsr loadSlot
        sta currentPiece
        iny
        jsr loadSlot
        sta nextPiece

        ; level/lines/score
        ; iny
        ; jsr loadSlot
        ; sta levelNumber
        ; iny
        ; jsr loadSlot
        ; sta lines
        ; iny
        ; jsr loadSlot
        ; sta score
        ; iny
        ; jsr loadSlot
        ; sta score+1
        ; iny
        ; jsr loadSlot
        ; sta score+2
        ; ; mark for update
        ; lda #7
        ; sta outOfDateRenderFlags

        lda #$18
        sta saveStateSpriteType
        lda #$20
        sta saveStateSpriteDelay
@done:
        rts

renderStateGameplay:
        lda #$03
        sta playState
        lda #1
        sta saveStateDirty ; cleared in game init
        lda #$20
        sta spawnDelay
        lda #$00
        sta tetriminoY
        lda #$05
        sta tetriminoX
        rts

renderStateDebug:
        jsr renderDebugPlayfield
        rts

checkDebugGameplay:
        lda debugFlag
        cmp #0
        beq @done

        ; sprite
        jsr renderDebugHUD

        ; controls
        lda heldButtons_player1
        and #BUTTON_SELECT
        beq @done

        lda newlyPressedButtons_player1
        and #BUTTON_B
        beq @done
        ldy #0
        jsr loadSlot ; check slot is empty
        beq @done
        jsr loadState
        jsr renderStateGameplay
        jmp @done
@done:
        rts

checkSaveStateControlsDebug:
        ; load / save
        lda newlyPressedButtons_player1
        and #BUTTON_B
        beq @notPressedB
        ldy #0
        jsr loadSlot ; check slot is empty
        beq @notPressedB
        jsr loadState
        jsr renderStateDebug
        jmp @notPressedA ; dont allow both actions to happen at once
@notPressedB:
        lda newlyPressedButtons_player1
        and #BUTTON_A
        beq @notPressedA
        jsr saveState
@notPressedA:
        ; save slot
        lda newlyPressedButtons_player1
        and #BUTTON_UP
        beq @notPressedUp
        jsr renderDebugSaveSlot
        inc saveStateSlot
        lda saveStateSlot
        cmp #$A
        bne @notPressedUp
        lda #0
        sta saveStateSlot
@notPressedUp:
        lda newlyPressedButtons_player1
        and #BUTTON_DOWN
        beq @notPressedDown
        lda saveStateSlot
        bne @noWrap
        lda #$A
        sta saveStateSlot
@noWrap:
        dec saveStateSlot
        jsr renderDebugSaveSlot
@notPressedDown:
        rts

renderDebugSaveSlot:
        lda pausedOutOfDateRenderFlags
        ora #$2
        sta pausedOutOfDateRenderFlags
        rts

renderDebugHUD:
        ; savestates
        lda saveStateSpriteDelay
        beq @noSprite
        dec saveStateSpriteDelay
        lda #$C0
        sta spriteXOffset
        lda #$C8
        sta spriteYOffset
        lda saveStateSpriteType
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging
@noSprite:
        rts

controllerInputTiles:
        ; .byte "RLDUSSBA"
        .byte $D0, $D1, $D2, $D3
        .byte $D4, $D4, $D5, $D5
controllerInputX:
        .byte $8, $0, $5, $4
        .byte $1D, $14, $27, $30
controllerInputY:
        .byte $FF, $0, $5, $FB
        .byte $0, $0, $FF, $FF

renderDebugPlayfield:
        lda #$00
        sta vramRow
        rts

debugSelectMenuControls:
        lda heldButtons_player1
        and #BUTTON_SELECT
        beq debugContinue

        lda newlyPressedButtons_player1
        and #BUTTON_LEFT+BUTTON_RIGHT
        beq @skipDebugType
        ; toggle mode
        lda debugLevelEdit
        eor #1
        sta debugLevelEdit
@skipDebugType:

        jsr checkSaveStateControlsDebug

        ; fallthrough

debugDrawPieces:
        jsr renderDebugHUD

        ; handle pieces / X
        jsr stageSpriteForNextPiece

        lda debugLevelEdit
        and #1
        bne @handleX
        jsr stageSpriteForCurrentPiece
        rts

@handleX:
        ; load X
        lda tetriminoX
        asl
        asl
        asl
        clc
        adc #$60
        sta spriteXOffset

        ; load Y
        lda tetriminoY
        asl
        asl
        asl
        clc
        adc #$2F
        sta spriteYOffset

        lda #$16
        sta spriteIndexInOamContentLookup
        jsr loadSpriteIntoOamStaging
        rts

pauseDrawPieces:
        jsr stageSpriteForNextPiece
        jsr stageSpriteForCurrentPiece
        rts

debugMode:

DEBUG_ORIGINAL_Y := tmp1
DEBUG_ORIGINAL_CURRENT_PIECE := tmp2

        lda debugFlag
        cmp #0
        beq pauseDrawPieces

        jmp debugSelectMenuControls
debugContinue:
        lda tetriminoX
        sta originalY
        lda tetriminoY
        sta DEBUG_ORIGINAL_Y
        lda currentPiece
        sta DEBUG_ORIGINAL_CURRENT_PIECE

        ; update position
        lda #BUTTON_UP
        jsr menuThrottle
        beq @notPressedUp
        dec tetriminoY
@notPressedUp:
        lda #BUTTON_DOWN
        jsr menuThrottle
        beq @notPressedDown
        inc tetriminoY
@notPressedDown:
        lda #BUTTON_LEFT
        jsr menuThrottle
        beq @notPressedLeft
        dec tetriminoX
@notPressedLeft:
        lda #BUTTON_RIGHT
        jsr menuThrottle
        beq @notPressedRight
        inc tetriminoX
@notPressedRight:

        ; check mode
        lda debugLevelEdit
        and #1
        bne handleLevelEditor

        ; handle next piece
        lda heldButtons_player1
        and #BUTTON_B
        beq @notPressedBothB
        lda newlyPressedButtons_player1
        and #BUTTON_A
        beq @notPressedBothB
        jmp @changeNext
@notPressedBothB:
        lda heldButtons_player1
        and #BUTTON_A
        beq @notPressedBothA
        lda newlyPressedButtons_player1
        and #BUTTON_B
        beq @notPressedBothA
        jmp @changeNext
@notPressedBothA:

        ; change current piece
        lda newlyPressedButtons_player1
        and #BUTTON_B
        beq @notPressedB
        lda currentPiece
        cmp #$1
        bmi @notPressedB
        dec currentPiece
@notPressedB:

        lda newlyPressedButtons_player1
        and #BUTTON_A
        beq @notPressedA
        lda currentPiece
        cmp #$12
        bpl @notPressedA
        inc currentPiece
@notPressedA:

        ; handle piece
        jsr isPositionValid
        bne @restore_
        jmp debugDrawPieces

@restore_:
        lda originalY
        sta tetriminoX
        lda DEBUG_ORIGINAL_Y
        sta tetriminoY
        lda DEBUG_ORIGINAL_CURRENT_PIECE
        sta currentPiece
        jmp debugDrawPieces

@changeNext:
        lda debugNextCounter
        and #7
        cmp #7
        bne @notDupe
        inc debugNextCounter
@notDupe:
        tax
        lda spawnTable,x
        sta nextPiece

        inc debugNextCounter
        jmp debugDrawPieces


handleLevelEditor:
        jsr debugDrawPieces

        ; handle editing

        lda newlyPressedButtons_player1
        and #BUTTON_B
        beq @notPressedB
        jsr @getPos
        ldx tmp3
        lda #EMPTY_TILE
        sta playfield, x
        jmp renderDebugPlayfield

@notPressedB:

        lda newlyPressedButtons_player1
        and #BUTTON_A
        beq @notPressedA
        jsr @getPos
        ldx tmp3
        lda #$7B
        sta playfield, x
        jmp renderDebugPlayfield

@notPressedA:

        rts

@getPos:
        ; multiply by 10
        ldx tetriminoY
        lda multBy10Table,x

        ; add X
        adc tetriminoX
        sta tmp3
        dec tmp3
        rts

; target = lines <= 110 ? scoreLookup : scoreLookup + ((lines - 110) / (230 - 110)) * 348
; pace = score - ((target / 230) * lines)

; rough guide: https://docs.google.com/spreadsheets/d/1FKUkx8borKvwwTFmFoM2j7FqMPFoJ4GkdFtO5JIekFE/edit#gid=465512309

lineTargetThreshold := 110

targetTable:
        .byte $0,$0,$0,$0
        .byte $68,$1,$4B,$0 ; 1
        .byte $F8,$2,$6E,$0 ; 2
        .byte $7E,$4,$9A,$0 ; 3
        .byte $E6,$5,$E5,$0 ; 4
        .byte $6C,$7,$12,$1 ; 5
        .byte $CA,$8,$67,$1 ; 6
        .byte $5A,$A,$89,$1 ; 7
        .byte $B8,$B,$DE,$1 ; 8
        .byte $3E,$D,$B,$2 ; 9
        .byte $F2,$E,$A,$2 ; A
        .byte $2C,$10,$83,$2 ; B
        .byte $94,$11,$CD,$2 ; C
        .byte $38,$13,$DC,$2 ; D
        .byte $B4,$14,$13,$3 ; E
        .byte $08,$16,$72,$3

prepareNextPace:
        ; lines BCD -> binary
        lda lines
        sta bcd32
        lda lines+1
        sta bcd32+1
        lda #0
        sta bcd32+2
        sta bcd32+3
        jsr BCD_BIN

        ; check if lines > 230
        lda binary32+1
        bne @moreThan230
        lda binary32
        cmp #230
        bcc @lessThan230
@moreThan230:
        lda #$AA
        sta paceResult
        sta paceResult+1
        sta paceResult+2
        rts
@lessThan230:

        ; use target multiplier as factor B
        jsr paceTarget

        ; use lines as factor A
        lda binary32
        sta factorA24
        lda #0
        sta factorA24+1
        sta factorA24+2

        ; get actual score target in product24
        jsr unsigned_mul24

        ; subtract target from score
        sec
        lda binScore
        sbc product24
        sta binaryTemp
        lda binScore+1
        sbc product24+1
        sta binaryTemp+1
        lda binScore+2
        sbc product24+2
        sta binaryTemp+2

        ; convert to unsigned, extract sign
        lda #0
        sta sign
        lda binaryTemp+2
        and #$80
        beq @positive
        lda #1
        sta sign
        lda binaryTemp
        eor #$FF
        adc #1
        sta binaryTemp
        lda binaryTemp+1
        eor #$FF
        sta binaryTemp+1
        lda binaryTemp+2
        eor #$FF
        sta binaryTemp+2
@positive:

        lda binaryTemp
        sta binary32
        lda binaryTemp+1
        sta binary32+1
        lda binaryTemp+2
        sta binary32+2
        lda #0
        sta binary32+3

        ; back to BCD
        jsr BIN_BCD

        ; reorder data
        lda bcd32
        sta paceResult+2
        lda bcd32+1
        sta paceResult+1
        lda bcd32+2
        sta paceResult

        ; check if highest nybble is empty and use it for a sign
        ldx #$B0
        lda sign
        sta paceSign
        beq @negative
        ldx #$A0
@negative:
        stx tmp3

        lda paceResult
        and #$F0
        bne @noSign
        lda paceResult
        adc tmp3
        sta paceResult
@noSign:

        rts

paceTarget:
        lda binary32
        cmp #lineTargetThreshold+1
        bcc @baseTarget

        sbc #lineTargetThreshold

        ; store the value as if multiplied by 100
        sta dividend+2
        lda #0
        sta dividend
        sta dividend+1

        ; / (230 - 110)
        lda #120
        sta divisor
        lda #0
        sta divisor+1
        sta divisor+2

        jsr unsigned_div24

        ; result in dividend, copy as first factor
        lda dividend+1
        sta factorA24
        lda dividend+2
        sta factorA24+1
        lda #0
        sta factorA24+2

        ; pace target multiplier as other factor
        jsr paceTargetOffset
        lda targetTable+2, x
        sta factorB24
        lda targetTable+3, x
        sta factorB24+1
        lda #0
        sta factorB24+2

        jsr unsigned_mul24

        ; additional target data now in product24

        ; we take the high bytes, so round the low one
        lda product24+0
        cmp #$80
        bcc @noRounding
        clc
        lda product24+1
        adc #1
        sta product24+1

        lda product24+2
        adc #0 ; this load/add/load has an effect if the carry flag is set
        sta product24+2
@noRounding:

        ; add the base target value to the additional target amount
        jsr paceTargetOffset
        clc
        lda product24+1
        adc targetTable, x
        sta product24
        lda product24+2
        adc targetTable+1, x
        sta product24+1
        lda #0
        adc #0
        sta product24+2

        ; use target as next factor
        lda product24+0
        sta factorB24+0
        lda product24+1
        sta factorB24+1
        lda product24+2
        sta factorB24+2

        jmp @done

@baseTarget:
        jsr paceTargetOffset
        lda targetTable, x
        sta factorB24
        lda targetTable+1, x
        sta factorB24+1
        lda #0
        sta factorB24+2
@done:
        rts

paceTargetOffset:
        lda paceModifier
        asl
        asl
        tax
        rts

gameHUDPace:
        lda #$C0
        sta spriteXOffset
        lda #$27
        sta spriteYOffset
        lda #<paceResult
        sta byteSpriteAddr
        lda #>paceResult
        sta byteSpriteAddr+1

        ldx #$E0
        lda paceSign
        beq @positive
        ldx #$F0
@positive:
        stx byteSpriteTile
        lda #3
        sta byteSpriteLen
        jsr byteSprite
        rts

; hz stuff

; hz = 60.098 * (taps - 1) / (frames - 1)
; PAL is 50.006
;
; HydrantDude explains how and why the formula works here: https://discord.com/channels/374368504465457153/405470199400235013/867156217259884574

hzDebounceThreshold := $10

hzStart: ; called in playState_spawnNextTetrimino, gameModeState_initGameState, gameMode_gameTypeMenu
        lda #0
        sta hzSpawnDelay
        sta hzTapCounter
        lda #hzDebounceThreshold
        sta hzDebounceCounter
        ; frame counter is reset on first tap
        rts

hzControl: ; called in playState_playerControlsActiveTetrimino, gameTypeLoopContinue
        lda hzTapCounter
        beq @notTapping
        ; tick frame counter
        lda hzFrameCounter
        clc
        adc #$01
        sta hzFrameCounter
        lda #$00
        adc hzFrameCounter+1
        sta hzFrameCounter+1
@notTapping:

        ; tick debounce counter
        lda hzDebounceCounter
        cmp #hzDebounceThreshold
        beq @elapsed
        inc hzDebounceCounter
@elapsed:

        ; detect inputs
        lda newlyPressedButtons_player1
        and #BUTTON_DPAD
        cmp #BUTTON_LEFT
        beq hzTap
        lda newlyPressedButtons_player1
        and #BUTTON_DPAD
        cmp #BUTTON_RIGHT
        beq hzTap

        lda hzTapCounter
        bne @noDelayInc
        lda hzSpawnDelay
        cmp #$F
        beq @noDelayInc
        inc hzSpawnDelay
@noDelayInc:
        rts

hzTap:
        tax ; button direction
        dex ; normalize to 1/0
        cpx hzTapDirection
        bne @fresh
        ; if debouncing meets threshold, this is a fresh tap
        lda hzDebounceCounter
        cmp #hzDebounceThreshold
        bne @within
@fresh:
        stx hzTapDirection
@wrap:
        lda #0
        sta hzTapCounter
        sta hzFrameCounter+1
        ; 0 is the first frame (4 means 5 frames)
        sta hzFrameCounter
@within:

        ; increment taps, reset debounce
        inc hzTapCounter
        lda hzTapCounter
        cmp #$10
        bcs @wrap
        lda #0
        sta hzDebounceCounter

        lda dasOnlyFlag
        beq :+
        lda #0
        sta dasOnlyShiftDisabled

        ldx hzTapCounter
        cpx #$A
        bcs @disableShift
        lda palFlag
        beq @NTSCDASOnly
        clc
        txa
        adc #$A
        tax
@NTSCDASOnly:
        lda dasLimitLookup, x
        sta tmpZ
        lda hzFrameCounter
        cmp tmpZ
        bpl :+
@disableShift:
        lda #1
        sta dasOnlyShiftDisabled
:

        ; ignore 1 tap
        lda hzTapCounter
        cmp #2
        bcc @calcEnd

        lda #$7A
        sta factorB24
        lda #$17
        sta factorB24+1
        lda #0
        sta factorA24+1
        sta factorA24+2
        sta factorB24+2

        lda hzTapCounter
        sbc #1
        sta factorA24

        lda palFlag
        beq @notPAL
        lda #$89
        sta factorB24
        lda #$13
        sta factorB24+1
@notPAL:

        jsr unsigned_mul24

        ; taps-1 * 6010 now in product24

        lda product24
        sta dividend
        lda product24+1
        sta dividend+1
        lda product24+2
        sta dividend+2

        ; then divide by the hzFrameCounter, which should be frames-1

        lda hzFrameCounter
        sta divisor
        lda hzFrameCounter+1
        sta divisor+1
        lda #0
        sta divisor+2

        jsr unsigned_div24 ; hz*100 in dividend

        ldx dividend+1 ; get hz for palette
        lda hzPaletteGradient, x
        sta hzPalette

        lda dividend
        sta binary32
        lda dividend+1
        sta binary32+1
        lda dividend+2
        sta binary32+2
        lda #0
        sta binary32+3

        jsr BIN_BCD ; hz*100 as BCD in bcd32

        lda bcd32
        sta hzResult+1
        lda bcd32+1
        sta hzResult

@calcEnd:

        ; update game UI
        lda outOfDateRenderFlags
        ora #$10 ; @renderHz
        sta outOfDateRenderFlags
        rts

dasLimitLookup:
        .byte 0, 0, 4, 11, 18, 24, 30, 36, 42 , 48; , 54, 60
        .byte 0, 0, 3, 7, 12, 16, 20, 24, 28, 32 ; PAL

; Kitaru on reddit - Thankfully, the same "round-down" effect also benefits DAS speed. Whereas the NTSC DAS timings were 16f start-up and 6f period, PAL DAS timings are 12f start-up and 4f period. Accounting for framerate, this is an improvement from NTSC DAS's real-time rate of 10Hz vs. PAL's real-time rate of 12.5Hz. So, although PAL hits its max gravity at Level 19 instead of Level 29, the boosted DAS makes it a bit more survivable. PAL DAS can still be out-tapped, albeit at a slimmer margin.

hzPaletteGradient: ; goes up to B
        .byte $16, $26, $27, $28, $29, $2a, $2c, $22, $23, $24, $14, $15

; End of "PRG_chunk1" segment
.code

.segment    "PRG_chunk2": absolute

.include "data/demo.asm"

; canon is updateAudio
updateAudio_jmp:
        jmp updateAudio

; canon is updateAudio
updateAudio2:
        jmp soundEffectSlot2_makesNoSound

LE006:  jmp LE1D8

; Referenced via updateSoundEffectSlotShared
soundEffectSlot0Init_table:
        .addr   soundEffectSlot0_makesNoSound
        .addr   soundEffectSlot0_gameOverCurtainInit
        .addr   soundEffectSlot0_endingRocketInit
soundEffectSlot0Playing_table:
        .addr   advanceSoundEffectSlot0WithoutUpdate
        .addr   updateSoundEffectSlot0_apu
        .addr   advanceSoundEffectSlot0WithoutUpdate
soundEffectSlot1Init_table:
        .addr   soundEffectSlot1_menuOptionSelectInit
        .addr   soundEffectSlot1_menuScreenSelectInit
        .addr   soundEffectSlot1_shiftTetriminoInit
        .addr   soundEffectSlot1_tetrisAchievedInit
        .addr   soundEffectSlot1_rotateTetriminoInit
        .addr   soundEffectSlot1_levelUpInit
        .addr   soundEffectSlot1_lockTetriminoInit
        .addr   soundEffectSlot1_chirpChirpInit
        .addr   soundEffectSlot1_lineClearingInit
        .addr   soundEffectSlot1_lineCompletedInit
soundEffectSlot1Playing_table:
        .addr   soundEffectSlot1_menuOptionSelectPlaying
        .addr   soundEffectSlot1_menuScreenSelectPlaying
        .addr   soundEffectSlot1Playing_advance
        .addr   soundEffectSlot1_tetrisAchievedPlaying
        .addr   soundEffectSlot1_rotateTetriminoPlaying
        .addr   soundEffectSlot1_levelUpPlaying
        .addr   soundEffectSlot1Playing_advance
        .addr   soundEffectSlot1_chirpChirpPlaying
        .addr   soundEffectSlot1_lineClearingPlaying
        .addr   soundEffectSlot1_lineCompletedPlaying
soundEffectSlot3Init_table:
        .addr   soundEffectSlot3_fallingAlien
        .addr   soundEffectSlot3_donk
soundEffectSlot3Playing_table:
        .addr   updateSoundEffectSlot3_apu
        .addr   soundEffectSlot3Playing_advance
; Referenced by unused slot 4 as well
soundEffectSlot2Init_table:
        .addr   soundEffectSlot2_makesNoSound
        .addr   soundEffectSlot2_lowBuzz
        .addr   soundEffectSlot2_mediumBuzz
; input y: $E100+y source addr
copyToSq1Channel:
        lda #$00
        beq copyToApuChannel
copyToTriChannel:
        lda #$08
        bne copyToApuChannel
copyToNoiseChannel:
        lda #$0C
        bne copyToApuChannel
copyToSq2Channel:
        lda #$04
; input a: $4000+a APU addr; input y: $E100+y source; copies 4 bytes
copyToApuChannel:
        sta AUDIOTMP1
        lda #$40
        sta AUDIOTMP2
        sty AUDIOTMP3
        lda #>soundEffectSlot0_gameOverCurtainInitData
        sta AUDIOTMP4
        ldy #$00
@copyByte:
        lda (AUDIOTMP3),y
        sta (AUDIOTMP1),y
        iny
        tya
        cmp #$04
        bne @copyByte
        rts

; input a: index-1 into table at $E000+AUDIOTMP1; output AUDIOTMP3/4: address; $EF set to a
computeSoundEffMethod:
        sta currentAudioSlot
        pha
        ldy #>soundEffectSlot0Init_table
        sty AUDIOTMP2
        ldy #$00
@whileYNot2TimesA:
        dec currentAudioSlot
        beq @copyAddr
        iny
        iny
        tya
        cmp #$22
        bne @whileYNot2TimesA
        lda #$91
        sta AUDIOTMP3
        lda #>soundEffectSlot0Init_table
        sta AUDIOTMP4
@ret:   pla
        sta currentAudioSlot
        rts

@copyAddr:
        lda (AUDIOTMP1),y
        sta AUDIOTMP3
        iny
        lda (AUDIOTMP1),y
        sta AUDIOTMP4
        jmp @ret

unreferenced_soundRng:
        lda $EB
        and #$02
        sta $06FF
        lda $EC
        and #$02
        eor $06FF
        clc
        beq @insertRandomBit
        sec
@insertRandomBit:
        ror $EB
        ror $EC
        rts

; Z=0 when returned means disabled
advanceAudioSlotFrame:
        ldx currentSoundEffectSlot
        inc soundEffectSlot0FrameCounter,x
        lda soundEffectSlot0FrameCounter,x
        cmp soundEffectSlot0FrameCount,x
        bne @ret
        lda #$00
        sta soundEffectSlot0FrameCounter,x
@ret:   rts

unreferenced_data3:
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $03,$7F,$0F,$C0
; Referenced by initSoundEffectShared
soundEffectSlot0_gameOverCurtainInitData:
        .byte   $1F,$7F,$0F,$C0
soundEffectSlot0_endingRocketInitData:
        .byte   $08,$7F,$0E,$C0
; Referenced at LE20F
unknown_sq1_data1:
        .byte   $9D,$7F,$7A,$28
; Referenced at LE20F
unknown_sq1_data2:
        .byte   $9D,$7F,$40,$28
soundEffectSlot1_rotateTetriminoInitData:
        .byte   $9E,$7F,$C0,$28
soundEffectSlot1Playing_rotateTetriminoStage3:
        .byte   $B2,$7F,$C0,$08
soundEffectSlot1_levelUpInitData:
        .byte   $DE,$7F,$A8,$18
soundEffectSlot1_lockTetriminoInitData:
        .byte   $9F,$84,$FF,$0B
soundEffectSlot1_menuOptionSelectInitData:
        .byte   $DB,$7F,$40,$28
soundEffectSlot1Playing_menuOptionSelectStage2:
        .byte   $D2,$7F,$40,$28
soundEffectSlot1_menuScreenSelectInitData:
        .byte   $D9,$7F,$84,$28
soundEffectSlot1_tetrisAchievedInitData:
        .byte   $9E,$9D,$C0,$08
soundEffectSlot1_lineCompletedInitData:
        .byte   $9C,$9A,$A0,$09
soundEffectSlot1_lineClearingInitData:
        .byte   $9E,$7F,$69,$08
soundEffectSlot1_chirpChirpInitData:
        .byte   $96,$7F,$36,$20
soundEffectSlot1Playing_chirpChirpStage2:
        .byte   $82,$7F,$30,$F8
soundEffectSlot1_shiftTetriminoInitData:
        .byte   $98,$7F,$80,$38
soundEffectSlot3_unknown1InitData:
        .byte   $30,$7F,$70,$08
soundEffectSlot3_unknown2InitData:
        .byte   $03,$7F,$3D,$18
soundEffectSlot1_chirpChirpSq1Vol_table:
        .byte   $14,$93,$94,$D3
; See getSoundEffectNoiseNibble
noiselo_table:
        .byte   $7A,$DE,$FF,$EF,$FD,$DF,$FE,$EF
        .byte   $EF,$FD,$EF,$FE,$DF,$FF,$EE,$EE
        .byte   $FF,$EF,$FF,$FF,$FF,$EF,$EF,$FF
        .byte   $FD,$DF,$DF,$EF,$FE,$DF,$EF,$FF
; Similar to noiselo_table. Nibble set to NOISE_VOL bits 0-3 with bit 4 set to 1
noisevol_table:
        .byte   $BF,$FF,$EE,$EF,$EF,$EF,$DF,$FB
        .byte   $BB,$AA,$AA,$99,$98,$87,$76,$66
        .byte   $55,$44,$44,$44,$44,$43,$33,$33
        .byte   $22,$22,$22,$22,$21,$11,$11,$11
updateSoundEffectSlot2:
        ldx #$02
        lda #<soundEffectSlot2Init_table
        ldy #<soundEffectSlot2Init_table
        bne updateSoundEffectSlotShared
updateSoundEffectSlot3:
        ldx #$03
        lda #<soundEffectSlot3Init_table
        ldy #<soundEffectSlot3Playing_table
        bne updateSoundEffectSlotShared
updateSoundEffectSlot4_unused:
        ldx #$04
        lda #<soundEffectSlot2Init_table
        ldy #<soundEffectSlot2Init_table
        bne updateSoundEffectSlotShared
updateSoundEffectSlot1:
        lda soundEffectSlot4Playing
        bne updateSoundEffectSlotShared_rts
        ldx #$01
        lda #<soundEffectSlot1Init_table
        ldy #<soundEffectSlot1Playing_table
        bne updateSoundEffectSlotShared
updateSoundEffectSlot0:
        ldx #$00
        lda #<soundEffectSlot0Init_table
        ldy #<soundEffectSlot0Playing_table
; x: sound effect slot; a: low byte addr, for $E0 high byte; y: low byte addr, for $E0 high byte, if slot unused
updateSoundEffectSlotShared:
.if !NO_SFX
        sta AUDIOTMP1
        stx currentSoundEffectSlot
        lda soundEffectSlot0Init,x
        beq @primaryIsEmpty
@computeAndExecute:
        jsr computeSoundEffMethod
        jmp (AUDIOTMP3)

@primaryIsEmpty:
        lda soundEffectSlot0Playing,x
        beq updateSoundEffectSlotShared_rts
        sty AUDIOTMP1
        bne @computeAndExecute
.endif
updateSoundEffectSlotShared_rts:
        rts

LE1D8:  lda #$0F
        sta SND_CHN
        lda #$55
        sta soundRngSeed
        jsr soundEffectSlot2_makesNoSound
        rts

initAudioAndMarkInited:
        inc audioInitialized
        jsr muteAudio
        sta musicPauseSoundEffectLengthCounter
        rts

handlePausedAudio:  lda audioInitialized
        beq initAudioAndMarkInited
        lda musicPauseSoundEffectLengthCounter
        cmp #$12
        beq LE215
        and #$03
        cmp #$03
        bne LE212
        inc musicPauseSoundEffectCounter
        ldy #$10
        lda musicPauseSoundEffectCounter
        and #$01
        bne LE20F
        ldy #<unknown_sq1_data1
LE20F:  jsr copyToSq1Channel
LE212:  inc musicPauseSoundEffectLengthCounter
LE215:  rts

; Disables APU frame interrupt
updateAudio:
        lda #$C0
        sta JOY2_APUFC
        lda musicStagingNoiseHi
        cmp #$05
        beq handlePausedAudio
        lda #$00
        sta audioInitialized
        sta musicPauseSoundEffectCounter
        jsr updateSoundEffectSlot2
        jsr updateSoundEffectSlot0
        jsr updateSoundEffectSlot3
        jsr updateSoundEffectSlot1
        jsr updateMusic
        lda #$00
        ldx #$06
@clearSoundEffectSlotsInit:
        sta $06EF,x
        dex
        bne @clearSoundEffectSlotsInit
        rts

soundEffectSlot2_makesNoSound:
        jsr LE253
muteAudioAndClearTriControl:
        jsr muteAudio
        lda #$00
        sta DMC_RAW
        sta musicChanControl+2
        rts

LE253:  lda #$00
        sta musicChanInhibit
        sta musicChanInhibit+1
        sta musicChanInhibit+2
        sta musicStagingNoiseLo
        sta resetSq12ForMusic
        tay
LE265:  lda #$00
        sta soundEffectSlot0Playing,y
        iny
        tya
        cmp #$06
        bne LE265
        rts

muteAudio:
        lda #$00
        sta DMC_RAW
        lda #$10
        sta SQ1_VOL
        sta SQ2_VOL
        sta NOISE_VOL
        lda #$00
        sta TRI_LINEAR
        rts

; inits currentSoundEffectSlot; input y: $E100+y to init APU channel (leaves alone if 0); input a: number of frames
initSoundEffectShared:
        ldx currentSoundEffectSlot
        sta soundEffectSlot0FrameCount,x
        txa
        sta $06C7,x
        tya
        beq @continue
        txa
        beq @slot0
        cmp #$01
        beq @slot1
        cmp #$02
        beq @slot2
        cmp #$03
        beq @slot3
        rts

@slot1: jsr copyToSq1Channel
        beq @continue
@slot2: jsr copyToSq2Channel
        beq @continue
@slot3: jsr copyToTriChannel
        beq @continue
@slot0: jsr copyToNoiseChannel
@continue:
        lda currentAudioSlot
        sta soundEffectSlot0Playing,x
        lda #$00
        sta soundEffectSlot0FrameCounter,x
        sta soundEffectSlot0SecondaryCounter,x
        sta soundEffectSlot0TertiaryCounter,x
        sta soundEffectSlot0Tmp,x
        sta resetSq12ForMusic
        rts

soundEffectSlot0_endingRocketInit:
        lda #$20
        ldy #<soundEffectSlot0_endingRocketInitData
        jmp initSoundEffectShared

setNoiseLo:
        sta NOISE_LO
        rts

loadNoiseLo:
        jsr getSoundEffectNoiseNibble
        jmp setNoiseLo

soundEffectSlot0_makesNoSound:
        lda #$10
        ldy #$00
        jmp initSoundEffectShared

advanceSoundEffectSlot0WithoutUpdate:
        jsr advanceAudioSlotFrame
        bne updateSoundEffectSlot0WithoutUpdate_ret
stopSoundEffectSlot0:
        lda #$00
        sta soundEffectSlot0Playing
        lda #$10
        sta NOISE_VOL
updateSoundEffectSlot0WithoutUpdate_ret:
        rts

unreferenced_code2:
        lda #$02
        sta currentAudioSlot
soundEffectSlot0_gameOverCurtainInit:
        lda #$40
        ldy #<soundEffectSlot0_gameOverCurtainInitData
        jmp initSoundEffectShared

updateSoundEffectSlot0_apu:
        jsr advanceAudioSlotFrame
        bne updateSoundEffectNoiseAudio
        jmp stopSoundEffectSlot0

updateSoundEffectNoiseAudio:
        ldx #<noiselo_table
        jsr loadNoiseLo
        ldx #<noisevol_table
        jsr getSoundEffectNoiseNibble
        ora #$10
        sta NOISE_VOL
        inc soundEffectSlot0SecondaryCounter
        rts

; Loads from noiselo_table(x=$54)/noisevol_table(x=$74)
getSoundEffectNoiseNibble:
        stx AUDIOTMP1
        ldy #>soundEffectSlot0_gameOverCurtainInitData
        sty AUDIOTMP2
        ldx soundEffectSlot0SecondaryCounter
        txa
        lsr a
        tay
        lda (AUDIOTMP1),y
        sta AUDIOTMP5
        txa
        and #$01
        beq @shift4
        lda AUDIOTMP5
        and #$0F
        rts

@shift4:lda AUDIOTMP5
        lsr a
        lsr a
        lsr a
        lsr a
        rts

LE33B:  lda soundEffectSlot1Playing
        cmp #$04
        beq LE34E
        cmp #$06
        beq LE34E
        cmp #$09
        beq LE34E
        cmp #$0A
        beq LE34E
LE34E:  rts

soundEffectSlot1_chirpChirpPlaying:
        lda soundEffectSlot1TertiaryCounter
        beq @stage1
        inc soundEffectSlot1SecondaryCounter
        lda soundEffectSlot1SecondaryCounter
        cmp #$16
        bne soundEffectSlot1Playing_ret
        jmp soundEffectSlot1Playing_stop

@stage1:lda soundEffectSlot1SecondaryCounter
        and #$03
        tay
        lda soundEffectSlot1_chirpChirpSq1Vol_table,y
        sta SQ1_VOL
        inc soundEffectSlot1SecondaryCounter
        lda soundEffectSlot1SecondaryCounter
        cmp #$08
        bne soundEffectSlot1Playing_ret
        inc soundEffectSlot1TertiaryCounter
        ldy #<soundEffectSlot1Playing_chirpChirpStage2
        jmp copyToSq1Channel

; Unused.
soundEffectSlot1_chirpChirpInit:
        ldy #<soundEffectSlot1_chirpChirpInitData
        jmp initSoundEffectShared

soundEffectSlot1_lockTetriminoInit:
        jsr LE33B
        beq soundEffectSlot1Playing_ret
        lda #$0F
        ldy #<soundEffectSlot1_lockTetriminoInitData
        jmp initSoundEffectShared

soundEffectSlot1_shiftTetriminoInit:
        jsr LE33B
        beq soundEffectSlot1Playing_ret
        lda #$02
        ldy #<soundEffectSlot1_shiftTetriminoInitData
        jmp initSoundEffectShared

soundEffectSlot1Playing_advance:
        jsr advanceAudioSlotFrame
        bne soundEffectSlot1Playing_ret
soundEffectSlot1Playing_stop:
        lda #$10
        sta SQ1_VOL
        lda #$00
        sta musicChanInhibit
        sta soundEffectSlot1Playing
        inc resetSq12ForMusic
soundEffectSlot1Playing_ret:
        rts

soundEffectSlot1_menuOptionSelectPlaying_ret:
        rts

soundEffectSlot1_menuOptionSelectPlaying:
        jsr advanceAudioSlotFrame
        bne soundEffectSlot1_menuOptionSelectPlaying_ret
        inc soundEffectSlot1SecondaryCounter
        lda soundEffectSlot1SecondaryCounter
        cmp #$02
        bne @stage2
        jmp soundEffectSlot1Playing_stop

@stage2:ldy #<soundEffectSlot1Playing_menuOptionSelectStage2
        jmp copyToSq1Channel

soundEffectSlot1_menuOptionSelectInit:
        lda #$03
        ldy #<soundEffectSlot1_menuOptionSelectInitData
        bne LE417
soundEffectSlot1_rotateTetrimino_ret:
        rts

soundEffectSlot1_rotateTetriminoInit:
        jsr LE33B
        beq soundEffectSlot1_rotateTetrimino_ret
        lda #$04
        ldy #<soundEffectSlot1_rotateTetriminoInitData
        jsr LE417
soundEffectSlot1_rotateTetriminoPlaying:
        jsr advanceAudioSlotFrame
        bne soundEffectSlot1_rotateTetrimino_ret
        lda soundEffectSlot1SecondaryCounter
        inc soundEffectSlot1SecondaryCounter
        beq @stage3
        cmp #$01
        beq @stage2
        cmp #$02
        beq @stage3
        cmp #$03
        bne soundEffectSlot1_rotateTetrimino_ret
        jmp soundEffectSlot1Playing_stop

@stage2:ldy #<soundEffectSlot1_rotateTetriminoInitData
        jmp copyToSq1Channel

; On first glance it appears this is used twice, but the first beq does nothing because the inc result will never be 0
@stage3:ldy #<soundEffectSlot1Playing_rotateTetriminoStage3
        jmp copyToSq1Channel

soundEffectSlot1_tetrisAchievedInit:
        lda #$05
        ldy palFlag
        cpy #0
        beq @ntsc
        lda #$4
@ntsc:
        ldy #<soundEffectSlot1_tetrisAchievedInitData
        jsr LE417
        lda #$10
        bne LE437
soundEffectSlot1_tetrisAchievedPlaying:
        jsr advanceAudioSlotFrame
        bne LE43A
        ldy #<soundEffectSlot1_tetrisAchievedInitData
        bne LE442
LE417:  jmp initSoundEffectShared

soundEffectSlot1_lineCompletedInit:
        lda #$05
        ldy palFlag
        cpy #0
        beq @ntsc
        lda #$4
@ntsc:
        ldy #<soundEffectSlot1_lineCompletedInitData
        jsr LE417
        lda #$08
        bne LE437
soundEffectSlot1_lineCompletedPlaying:
        jsr advanceAudioSlotFrame
        bne LE43A
        ldy #<soundEffectSlot1_lineCompletedInitData
        bne LE442
soundEffectSlot1_lineClearingInit:
        lda #$04
        ldy palFlag
        cpy #0
        beq @ntsc
        lda #$3
@ntsc:
        ldy #<soundEffectSlot1_lineClearingInitData
        jsr LE417
        lda #$00
LE437:  sta soundEffectSlot1TertiaryCounter
LE43A:  rts

soundEffectSlot1_lineClearingPlaying:
        jsr advanceAudioSlotFrame
        bne LE43A
        ldy #<soundEffectSlot1_lineClearingInitData
LE442:  jsr copyToSq1Channel
        clc
        lda soundEffectSlot1TertiaryCounter
        adc soundEffectSlot1SecondaryCounter
        tay
        lda unknown1_table,y
        sta SQ1_LO
        ldy soundEffectSlot1SecondaryCounter
        lda sq1vol_unknown2_table,y
        sta SQ1_VOL
        bne LE46F
        lda soundEffectSlot1Playing
        cmp #$04
        bne LE46C
        lda #$09
        sta currentAudioSlot
        jmp soundEffectSlot1_lineClearingInit

LE46C:  jmp soundEffectSlot1Playing_stop

LE46F:  inc soundEffectSlot1SecondaryCounter
LE472:  rts

soundEffectSlot1_menuScreenSelectInit:
        lda #$03
        ldy #<soundEffectSlot1_menuScreenSelectInitData
        jsr initSoundEffectShared
        lda soundEffectSlot1_menuScreenSelectInitData+2
        sta soundEffectSlot1SecondaryCounter
        rts

soundEffectSlot1_menuScreenSelectPlaying:
        jsr advanceAudioSlotFrame
        bne LE472
        inc soundEffectSlot1TertiaryCounter
        lda soundEffectSlot1TertiaryCounter
        cmp #$04
        bne LE493
        jmp soundEffectSlot1Playing_stop

LE493:  lda soundEffectSlot1SecondaryCounter
        lsr a
        lsr a
        lsr a
        lsr a
        sta soundEffectSlot1Tmp
        lda soundEffectSlot1SecondaryCounter
        clc
        sbc soundEffectSlot1Tmp
        sta soundEffectSlot1SecondaryCounter
        sta SQ1_LO
        lda #$28
LE4AC:  sta SQ1_HI
LE4AF:  rts

sq1vol_unknown2_table:
        .byte   $9E,$9B,$99,$96,$94,$93,$92,$91
        .byte   $00
unknown1_table:
        .byte   $46,$37,$46,$37,$46,$37,$46,$37
        .byte   $70,$80,$90,$A0,$B0,$C0,$D0,$E0
        .byte   $C0,$89,$B8,$68,$A0,$50,$90,$40
soundEffectSlot1_levelUpPlaying:
        jsr advanceAudioSlotFrame
        bne LE4AF
        ldy soundEffectSlot1SecondaryCounter
        inc soundEffectSlot1SecondaryCounter
        lda unknown18_table,y
        beq LE4E9
        sta SQ1_LO
        lda #$28
        jmp LE4AC

LE4E9:  jmp soundEffectSlot1Playing_stop

soundEffectSlot1_levelUpInit:
        lda #$06
        ldy palFlag
        cpy #0
        beq @ntsc
        lda #$5
@ntsc:
        ldy #<soundEffectSlot1_levelUpInitData
        jmp initSoundEffectShared

unknown18_table:
        .byte   $69,$A8,$69,$A8,$8D,$53,$8D,$53
        .byte   $8D,$00,$A9,$10,$8D,$04,$40,$A9
        .byte   $00,$8D,$C9,$06,$8D,$FA,$06,$60
; Unused
soundEffectSlot2_mediumBuzz:
        .byte   $A9,$3F,$A0,$60,$A2,$0F
        bne LE51B
; Unused
soundEffectSlot2_lowBuzz:
        lda #$3F
        ldy #$60
        ldx #$0E
        bne LE51B
LE51B:  sta DMC_LEN
        sty DMC_START
        stx DMC_FREQ
        lda #$0F
        sta SND_CHN
        lda #$00
        sta DMC_RAW
        lda #$1F
        sta SND_CHN
        rts

; Unused
soundEffectSlot3_donk:
        lda #$02
        ldy #$4C
        jmp initSoundEffectShared

soundEffectSlot3Playing_advance:
        jsr advanceAudioSlotFrame
        bne soundEffectSlot3Playing_ret
soundEffectSlot3Playing_stop:
        lda #$00
        sta TRI_LINEAR
        sta musicChanInhibit+2
        sta soundEffectSlot3Playing
        lda #$18
        sta TRI_HI
soundEffectSlot3Playing_ret:
        rts

updateSoundEffectSlot3_apu:
        jsr advanceAudioSlotFrame
        bne soundEffectSlot3Playing_ret
        ldy soundEffectSlot3SecondaryCounter
        inc soundEffectSlot3SecondaryCounter
        lda trilo_table,y
        beq soundEffectSlot3Playing_stop
        sta TRI_LO
        sta soundEffectSlot3TertiaryCounter
        lda soundEffectSlot3_unknown1InitData+3
        sta TRI_HI
        rts

; Unused
soundEffectSlot3_fallingAlien:
        lda #$06
        ldy #<soundEffectSlot3_unknown1InitData
        jsr initSoundEffectShared
        lda soundEffectSlot3_unknown1InitData+2
        sta soundEffectSlot3TertiaryCounter
        rts

trilo_table:
        .byte   $72,$74,$77,$00
updateMusic_noSoundJmp:
        jmp soundEffectSlot2_makesNoSound

updateMusic:
        lda musicTrack
        tay
        cmp #$FF
        beq updateMusic_noSoundJmp
        cmp #$00
        beq @checkIfAlreadyPlaying
        sta currentAudioSlot
        sta musicTrack_dec
        dec musicTrack_dec
        lda #$7F
        sta musicStagingSq1Sweep
        sta musicStagingSq1Sweep+1
        jsr loadMusicTrack
@updateFrame:
        jmp updateMusicFrame

@checkIfAlreadyPlaying:
        lda currentlyPlayingMusicTrack
        bne @updateFrame
        rts

; triples of bytes, one for each MMIO
noises_table:
        .byte   $00,$10,$01,$18,$00,$01,$38,$00
        .byte   $03,$40,$00,$06,$58,$00,$0A,$38
        .byte   $02,$04,$40,$13,$05,$40,$14,$0A
        .byte   $40,$14,$08,$40,$12,$0E,$08,$16
        .byte   $0E,$28,$16,$0B,$18
; input x: channel number (0-3). Does nothing for track 1 and NOISE
updateMusicFrame_setChanLo:
        lda currentlyPlayingMusicTrack
        cmp #$01
        beq @ret
        txa
        cmp #$03
        beq @ret
        lda musicChanControl,x
        and #$E0
        beq @ret
        sta AUDIOTMP1
        lda musicChanNote,x
        cmp #$02
        beq @incAndRet
        ldy musicChannelOffset
        lda musicStagingSq1Lo,y
        sta AUDIOTMP2
        jsr updateMusicFrame_setChanLoOffset
@incAndRet:
        inc musicChanLoFrameCounter,x
@ret:   rts

musicLoOffset_8AndC:
        lda AUDIOTMP3
        cmp #$31
        bne @lessThan31
        lda #$27
@lessThan31:
        tay
        lda loOff9To0FallTable,y
        pha
        lda musicChanNote,x
        cmp #$46
        bne LE613
        pla
        lda #$00
        beq musicLoOffset_setLoAndSaveFrameCounter
LE613:  pla
        jmp musicLoOffset_setLoAndSaveFrameCounter

; Doesn't loop
musicLoOffset_4:
        lda AUDIOTMP3
        tay
        cmp #$10
        bcs @outOfRange
        lda loOffDescendToNeg11BounceToNeg9Table,y
        jmp musicLoOffset_setLo

@outOfRange:
        lda #$F6
        bne musicLoOffset_setLo
; Every frame is the same
musicLoOffset_minus2_6:
        lda musicChanNote,x
        cmp #$4C
        bcc @unnecessaryBranch
        lda #$FE
        bne musicLoOffset_setLo
@unnecessaryBranch:
        lda #$FE
        bne musicLoOffset_setLo
; input x: channel number (0-2). input AUDIOTMP1: musicChanControl masked by #$E0. input AUDIOTMP2: base LO
updateMusicFrame_setChanLoOffset:
        lda musicChanLoFrameCounter,x
        sta AUDIOTMP3
        lda AUDIOTMP1
        cmp #$20
        beq @2AndE
        cmp #$A0
        beq @A
        cmp #$60
        beq musicLoOffset_minus2_6
        cmp #$40
        beq musicLoOffset_4
        cmp #$80
        beq musicLoOffset_8AndC
        cmp #$C0
        beq musicLoOffset_8AndC
; Loops between 0-9
@2AndE: lda AUDIOTMP3
        cmp #$0A
        bne @2AndE_lessThanA
        lda #$00
@2AndE_lessThanA:
        tay
        lda loOffTrillNeg2To2Table,y
        jmp musicLoOffset_setLoAndSaveFrameCounter

; Ends by looping in 2 and E table
@A:     lda AUDIOTMP3
        cmp #$2B
        bne @A_lessThan2B
        lda #$21
@A_lessThan2B:
        tay
        lda loOffSlowStartTrillTable,y
musicLoOffset_setLoAndSaveFrameCounter:
        pha
        tya
        sta musicChanLoFrameCounter,x
        pla
musicLoOffset_setLo:
        pha
        lda musicChanInhibit,x
        bne @ret
        pla
        clc
        adc AUDIOTMP2
        ldy musicChannelOffset
        sta SQ1_LO,y
        rts

@ret:   pla
        rts

; Values are signed
loOff9To0FallTable:
        .byte   $09,$08,$07,$06,$05,$04,$03,$02
        .byte   $02,$01,$01,$00
; Includes next table
loOffSlowStartTrillTable:
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$01
        .byte   $00,$00,$00,$00,$FF,$00,$00,$00
        .byte   $00,$01,$01,$00,$00,$00,$FF,$FF
        .byte   $00
loOffTrillNeg2To2Table:
        .byte   $00,$01,$01,$02,$01,$00,$FF,$FF
        .byte   $FE,$FF
loOffDescendToNeg11BounceToNeg9Table:
        .byte   $00,$FF,$FE,$FD,$FC,$FB,$FA,$F9
        .byte   $F8,$F7,$F6,$F5,$F6,$F7,$F6,$F5
copyFFFFToDeref:
        lda #$FF
        sta musicDataChanPtrDeref,x
        bne storeDeref1AndContinue
loadMusicTrack:
        jsr muteAudioAndClearTriControl
        lda currentAudioSlot
        sta currentlyPlayingMusicTrack
        lda musicTrack_dec
        tay
        lda musicDataTableIndex,y
        tay
        ldx #$00
@copyByteToMusicData:
        lda musicDataTable,y
        sta musicDataNoteTableOffset,x
        iny
        inx
        txa
        cmp #$0A
        bne @copyByteToMusicData
        lda #$01
        sta musicChanNoteDurationRemaining
        sta musicChanNoteDurationRemaining+1
        sta musicChanNoteDurationRemaining+2
        sta musicChanNoteDurationRemaining+3
        lda #$00
        sta music_unused2
        ldy #$08
@zeroFillDeref:
        sta musicDataChanPtrDeref+7,y
        dey
        bne @zeroFillDeref
        tax
derefNextAddr:
        lda musicDataChanPtr,x
        sta musicChanTmpAddr
        lda musicDataChanPtr+1,x
        cmp #$FF
        beq copyFFFFToDeref
        sta musicChanTmpAddr+1
        ldy musicDataChanPtrOff
        lda (musicChanTmpAddr),y
        sta musicDataChanPtrDeref,x
        iny
        lda (musicChanTmpAddr),y
storeDeref1AndContinue:
        sta musicDataChanPtrDeref+1,x
        inx
        inx
        txa
        cmp #$08
        bne derefNextAddr
        rts

initSq12IfTrashedBySoundEffect:
        lda resetSq12ForMusic
        beq initSq12IfTrashedBySoundEffect_ret
        cmp #$01
        beq @setSq1
        lda #$7F
        sta SQ2_SWEEP
        lda musicStagingSq2Lo
        sta SQ2_LO
        lda musicStagingSq2Hi
        sta SQ2_HI
@setSq1:lda #$7F
        sta SQ1_SWEEP
        lda musicStagingSq1Lo
        sta SQ1_LO
        lda musicStagingSq1Hi
        sta SQ1_HI
        lda #$00
        sta resetSq12ForMusic
initSq12IfTrashedBySoundEffect_ret:
        rts

; input x: channel number (0-3). Does nothing for SQ1/2
updateMusicFrame_setChanVol:
        txa
        cmp #$02
        bcs initSq12IfTrashedBySoundEffect_ret
        lda musicChanControl,x
        and #$1F
        beq @ret
        sta AUDIOTMP2
        lda musicChanNote,x
        cmp #$02
        beq @muteAndAdvanceFrame
        ldy #$00
@controlMinus1Times2_storeToY:
        dec AUDIOTMP2
        beq @loadFromTable
        iny
        iny
        bne @controlMinus1Times2_storeToY
@loadFromTable:
        lda musicChanVolControlTable,y
        sta AUDIOTMP3
        lda musicChanVolControlTable+1,y
        sta AUDIOTMP4
        lda musicChanVolFrameCounter,x
        lsr a
        tay
        lda (AUDIOTMP3),y
        sta AUDIOTMP5
        cmp #$FF
        beq @constVolAtEnd
        cmp #$F0
        beq @muteAtEnd
        lda musicChanVolFrameCounter,x
        and #$01
        bne @useNibbleFromTable
        lsr AUDIOTMP5
        lsr AUDIOTMP5
        lsr AUDIOTMP5
        lsr AUDIOTMP5
@useNibbleFromTable:
        lda AUDIOTMP5
        and #$0F
        sta AUDIOTMP1
        lda musicChanVolume,x
        and #$F0
        ora AUDIOTMP1
        tay
@advanceFrameAndSetVol:
        inc musicChanVolFrameCounter,x
@setVol:lda musicChanInhibit,x
        bne @ret
        tya
        ldy musicChannelOffset
        sta SQ1_VOL,y
@ret:   rts

@constVolAtEnd:
        ldy musicChanVolume,x
        bne @setVol
; Only seems valid for NOISE
@muteAtEnd:
        ldy #$10
        bne @setVol
; Only seems valid for NOISE
@muteAndAdvanceFrame:
        ldy #$10
        bne @advanceFrameAndSetVol
;
updateMusicFrame_progLoadNextScript:
        iny
        lda (musicChanTmpAddr),y
        sta musicDataChanPtr,x
        iny
        lda (musicChanTmpAddr),y
        sta musicDataChanPtr+1,x
        lda musicDataChanPtr,x
        sta musicChanTmpAddr
        lda musicDataChanPtr+1,x
        sta musicChanTmpAddr+1
        txa
        lsr a
        tax
        lda #$00
        tay
        sta musicDataChanPtrOff,x
        jmp updateMusicFrame_progLoadRoutine

updateMusicFrame_progEnd:
        jsr soundEffectSlot2_makesNoSound
updateMusicFrame_ret:
        rts

updateMusicFrame_progNextRoutine:
        txa
        asl a
        tax
        lda musicDataChanPtr,x
        sta musicChanTmpAddr
        lda musicDataChanPtr+1,x
        sta musicChanTmpAddr+1
        txa
        lsr a
        tax
        inc musicDataChanPtrOff,x
        inc musicDataChanPtrOff,x
        ldy musicDataChanPtrOff,x
; input musicChanTmpAddr: current channel's musicDataChanPtr. input y: offset. input x: channel number (0-3)
updateMusicFrame_progLoadRoutine:
        txa
        asl a
        tax
        lda (musicChanTmpAddr),y
        sta musicDataChanPtrDeref,x
        iny
        lda (musicChanTmpAddr),y
        sta musicDataChanPtrDeref+1,x
        cmp #$00
        beq updateMusicFrame_progEnd
        cmp #$FF
        beq updateMusicFrame_progLoadNextScript
        txa
        lsr a
        tax
        lda #$00
        sta musicDataChanInstructionOffset,x
        lda #$01
        sta musicChanNoteDurationRemaining,x
        bne updateMusicFrame_updateChannel
;
updateMusicFrame_progNextRoutine_jmp:
        jmp updateMusicFrame_progNextRoutine

updateMusicFrame:
        jsr initSq12IfTrashedBySoundEffect
        lda #$00
        tax
        sta musicChannelOffset
        beq updateMusicFrame_updateChannel
; input x: channel number * 2
updateMusicFrame_incSlotFromOffset:
        txa
        lsr a
        tax
; input x: channel number (0-3)
updateMusicFrame_incSlot:
        inx
        txa
        cmp #$04
        beq updateMusicFrame_ret
        lda musicChannelOffset
        clc
        adc #$04
        sta musicChannelOffset
; input x: channel number (0-3)
updateMusicFrame_updateChannel:
        txa
        asl a
        tax
        lda musicDataChanPtrDeref,x
        sta musicChanTmpAddr
        lda musicDataChanPtrDeref+1,x
        sta musicChanTmpAddr+1
        lda musicDataChanPtrDeref+1,x
        cmp #$FF
        beq updateMusicFrame_incSlotFromOffset
        txa
        lsr a
        tax
        dec musicChanNoteDurationRemaining,x
        bne @updateChannelFrame
        lda #$00
        sta musicChanVolFrameCounter,x
        sta musicChanLoFrameCounter,x
@processChannelInstruction:
        jsr musicGetNextInstructionByte
        beq updateMusicFrame_progNextRoutine_jmp
        cmp #$9F
        beq @setControlAndVolume
        cmp #$9E
        beq @setDurationOffset
        cmp #$9C
        beq @setNoteOffset
        tay
        cmp #$FF
        beq @endLoop
        and #$C0
        cmp #$C0
        beq @startForLoop
        jmp @noteAndMaybeDuration

@endLoop:
        lda musicChanProgLoopCounter,x
        beq @processChannelInstruction_jmp
        dec musicChanProgLoopCounter,x
        lda musicDataChanInstructionOffsetBackup,x
        sta musicDataChanInstructionOffset,x
        bne @processChannelInstruction_jmp
; Low 6 bits are number of times to run loop (1 == run code once)
@startForLoop:
        tya
        and #$3F
        sta musicChanProgLoopCounter,x
        dec musicChanProgLoopCounter,x
        lda musicDataChanInstructionOffset,x
        sta musicDataChanInstructionOffsetBackup,x
@processChannelInstruction_jmp:
        jmp @processChannelInstruction

@updateChannelFrame:
        jsr updateMusicFrame_setChanVol
        jsr updateMusicFrame_setChanLo
        jmp updateMusicFrame_incSlot

@playDmcAndNoise_jmp:
        jmp @playDmcAndNoise

@applyDurationForTri_jmp:
        jmp @applyDurationForTri

@setControlAndVolume:
        jsr musicGetNextInstructionByte
        sta musicChanControl,x
        jsr musicGetNextInstructionByte
        sta musicChanVolume,x
        jmp @processChannelInstruction

@unreferenced_code3:
        jsr musicGetNextInstructionByte
        jsr musicGetNextInstructionByte
        jmp @processChannelInstruction

@setDurationOffset:
        jsr musicGetNextInstructionByte
        sta musicDataDurationTableOffset
        jmp @processChannelInstruction

@setNoteOffset:
        jsr musicGetNextInstructionByte
        sta musicDataNoteTableOffset
        jmp @processChannelInstruction

; Duration, if present, is first
@noteAndMaybeDuration:
        tya
        and #$B0
        cmp #$B0
        bne @processNote
        tya
        and #$0F
        clc
        adc musicDataDurationTableOffset
        tay
        lda noteDurationTable,y
        sta musicChanNoteDuration,x
        tay
        txa
        cmp #$02
        beq @applyDurationForTri_jmp
@loadNextAsNote:
        jsr musicGetNextInstructionByte
        tay
@processNote:
        tya
        sta musicChanNote,x
        txa
        cmp #$03
        beq @playDmcAndNoise_jmp
        pha
        ldx musicChannelOffset
        lda noteToWaveTable+1,y
        beq @determineVolume
        lda musicDataNoteTableOffset
        bpl @signMagnitudeIsPositive
        and #$7F
        sta AUDIOTMP4
        tya
        clc
        sbc AUDIOTMP4
        jmp @noteOffsetApplied

@signMagnitudeIsPositive:
        tya
        clc
        adc musicDataNoteTableOffset
@noteOffsetApplied:
        tay
        lda noteToWaveTable+1,y
        sta musicStagingSq1Lo,x
        lda noteToWaveTable,y
        ora #$08
        sta musicStagingSq1Hi,x
; Complicated way to determine if we skipped setting lo/hi, maybe because of the needed pla. If we set lo/hi (by falling through from above), then we'll go to @loadVolume. If we jmp'ed here, then we'll end up muting the volume
@determineVolume:
        tay
        pla
        tax
        tya
        bne @loadVolume
        lda #$00
        sta AUDIOTMP1
        txa
        cmp #$02
        beq @checkChanControl
        lda #$10
        sta AUDIOTMP1
        bne @checkChanControl
;
@loadVolume:
        lda musicChanVolume,x
        sta AUDIOTMP1
; If any of 5 low bits of control is non-zero, then mute
@checkChanControl:
        txa
        dec musicChanInhibit,x
        cmp musicChanInhibit,x
        beq @channelInhibited
        inc musicChanInhibit,x
        ldy musicChannelOffset
        txa
        cmp #$02
        beq @useDirectVolume
        lda musicChanControl,x
        and #$1F
        beq @useDirectVolume
        lda AUDIOTMP1
        cmp #$10
        beq @setMmio
        and #$F0
        ora #$00
        bne @setMmio
@useDirectVolume:
        lda AUDIOTMP1
@setMmio:
        sta SQ1_VOL,y
        lda musicStagingSq1Sweep,x
        sta SQ1_SWEEP,y
        lda musicStagingSq1Lo,y
        sta SQ1_LO,y
        lda musicStagingSq1Hi,y
        sta SQ1_HI,y
@copyDurationToRemaining:
        lda musicChanNoteDuration,x
        sta musicChanNoteDurationRemaining,x
        jmp updateMusicFrame_incSlot

; Never triggered
@channelInhibited:
        inc musicChanInhibit,x
        jmp @copyDurationToRemaining

; input y: duration of 60Hz frames. TRI has no volume control. The volume MMIO for TRI goes to a linear counter. While the length counter can be disabled, that doesn't appear possible for the linear counter.
@applyDurationForTri:
        lda musicChanControl+2
        and #$1F
        bne @setTriVolume
        lda musicChanControl+2
        and #$C0
        bne @highCtrlImpliesOn
@useDuration:
        tya
        bne @durationToLinearClock
@highCtrlImpliesOn:
        cmp #$C0
        beq @useDuration
        lda #$FF
        bne @setTriVolume
; Not quite clear what the -1 is for. Times 4 because the linear clock counts quarter frames
@durationToLinearClock:
        clc
        adc #$FF
        asl a
        asl a
        cmp #$3C
        bcc @setTriVolume
        lda #$3C
@setTriVolume:
        sta musicChanVolume+2
        jmp @loadNextAsNote

@playDmcAndNoise:
        tya
        pha
        jsr playDmc
        pla
        and #$3F
        tay
        jsr playNoise
        jmp @copyDurationToRemaining

; Weird that it references slot 0. Slot 3 would make most sense as NOISE channel and slot 1 would make sense if the point was to avoid noise during a sound effect. But slot 0 isn't used very often
playNoise:
        lda soundEffectSlot0Playing
        bne @ret
        lda noises_table,y
        sta NOISE_VOL
        lda noises_table+1,y
        sta NOISE_LO
        lda noises_table+2,y
        sta NOISE_HI
@ret:   rts

playDmc:tya
        and #$C0
        cmp #$40
        beq @loadDmc0
        cmp #$80
        beq @loadDmc1
        rts

; dmc0
@loadDmc0:
        lda #$0E
        sta AUDIOTMP2
        lda #$07
        ldy #$00
        beq @loadIntoDmc
; dmc1
@loadDmc1:
        lda #$0E
        sta AUDIOTMP2
        lda #$0F
        ldy #$02
; Note that bit 4 in SND_CHN is 0. That disables DMC. It enables all channels but DMC
@loadIntoDmc:
        sta DMC_LEN
        sty DMC_START
        lda $06F7
        bne @ret
        lda AUDIOTMP2
        sta DMC_FREQ
        lda #$0F
        sta SND_CHN
        lda #$00
        sta DMC_RAW
        lda #$1F
        sta SND_CHN
@ret:   rts

; input x: music channel. output a: next value
musicGetNextInstructionByte:
        ldy musicDataChanInstructionOffset,x
        inc musicDataChanInstructionOffset,x
        lda (musicChanTmpAddr),y
        rts

musicChanVolControlTable:
noteToWaveTable:
noteDurationTable:
musicDataTableIndex:
musicDataTable:

.if PRACTISE_MODE

practisePrepareNext:
        lda practiseType
        cmp #MODE_PACE
        bne @skipPace
        jmp prepareNextPace
@skipPace:
        cmp #MODE_GARBAGE
        bne @skipGarbo
        jmp prepareNextGarbage
@skipGarbo:
        cmp #MODE_PARITY
        bne @skipParity
        jmp prepareNextParity
@skipParity:
        cmp #MODE_TAPQTY
        bne @skipTapQuantity
        jsr prepareNextTapQuantity
@skipTapQuantity:
        rts
practiseInitGameState:
        lda practiseType
        cmp #MODE_TAPQTY
        bne @skipTapQuantity
        jsr prepareNextTapQuantity
@skipTapQuantity:
        lda practiseType
        cmp #MODE_CHECKERBOARD
        bne @skipChecker
        jsr initChecker
@skipChecker:
        rts

practiseAdvanceGame:
        lda practiseType
        cmp #MODE_TSPINS
        bne @skipTSpins
        jmp advanceGameTSpins
@skipTSpins:
        cmp #MODE_PRESETS
        bne @skipPresets
        jmp advanceGamePreset
@skipPresets:
        cmp #MODE_FLOOR
        bne @skipFloor
        jmp advanceGameFloor
@skipFloor:
        cmp #MODE_TAP
        bne @skipTap
        jmp advanceGameTap
@skipTap:
        rts

practiseGameHUD:
        lda inputDisplayFlag
        beq @noInput
        jsr controllerInputDisplay
@noInput:

        lda practiseType
        cmp #MODE_PACE
        bne @skipPace
        jsr gameHUDPace
@skipPace:

        lda practiseType
        cmp #MODE_TAPQTY
        bne @skipTapQuantity

        ldy #0
        ldx oamStagingLength
@drawQTY:
        ; taps
        tya
        asl
        asl
        asl
        adc #$34
        sta tmpY
        sta oamStaging, x
        inx
        lda tqtyCurrent, y
        cmp #5
        bmi @right0
        sbc #5
        jmp @left0
@right0:
        lda #6
        sbc tqtyCurrent, y
@left0:
        sta oamStaging, x
        inx
        lda #$02
        sta oamStaging, x
        inx
        lda #$64
        sta oamStaging, x
        inx

        ; direction
        lda tmpY
        sta oamStaging, x
        inx

        lda tqtyCurrent, y
        cmp #6
        bmi @right
        lda #$D6
        jmp @left
@right:
        lda #$D7
@left:
        sta oamStaging, x
        inx
        lda #$02
        sta oamStaging, x
        inx
        lda #$6E
        sta oamStaging, x
        inx

        ; $D6 / D7 for direction
        ; increase OAM index
        lda #$08
        clc
        adc oamStagingLength
        sta oamStagingLength
        iny
        cpy #2
        bmi @drawQTY

@skipTapQuantity:
        rts

controllerInputDisplay:
        lda #0
        sta tmp3
controllerInputDisplayX:
        lda heldButtons_player1
        sta tmp1
        ldy #0
@inputLoop:
        lda tmp1
        and #1
        beq @inputContinue
        ldx oamStagingLength
        lda controllerInputY, y
        adc #$4C
        sta oamStaging, x
        inx
        lda controllerInputTiles, y
        sta oamStaging, x
        inx
        lda #$01
        sta oamStaging, x
        inx
        lda controllerInputX, y
        adc #$13
        adc tmp3
        sta oamStaging, x
        inx
        ; increase OAM index
        lda #$04
        clc
        adc oamStagingLength
        sta oamStagingLength
@inputContinue:
        lda tmp1
        ror
        sta tmp1
        iny
        cpy #8
        bmi @inputLoop
        rts

clearPlayfield:
        lda #EMPTY_TILE
        ldx #$C8
@loop:
        sta $0400, x
        dex
        bne @loop
        rts

prepareNextTapQuantity:
; patch in @updatePlayfieldComplete
@checkEqual:
        lda tqtyNext
        cmp tqtyCurrent
        bne @notEqual
        jsr random10
        sta tqtyNext
        jmp @checkEqual
@notEqual:

        ; playfield
        sec
        lda tapqtyModifier
        and #$F
        tax
        cpx #0
        bne @notZero
        ldx #4 ; default to four
@notZero:
        lda multBy10Table, x
        sta tmp1
        lda #$c8
        sbc tmp1
        sta tmp1 ; starting offset

        ldx #0
@drawLoop:
        lda #BLOCK_TILES
        cpx tmp1
        bcs @saveMino
        lda #EMPTY_TILE
@saveMino:
        sta playfield, x
        inx
        cpx #$c8
        bcc @drawLoop

        ; wells
        clc
        lda tmp1
        tax
@nextLoop:
        txa
        adc tqtyCurrent
        tay
        lda #EMPTY_TILE
        sta playfield, y

        txa
        adc tqtyNext
        tay
        lda #BLOCK_TILES+1
        sta playfield, y

        txa
        adc #10
        tax
        cpx #$c8
        bcc @nextLoop
        rts

initChecker:
CHECKERBOARD_TILE := BLOCK_TILES
CHECKERBOARD_FLIP := CHECKERBOARD_TILE ^ EMPTY_TILE
        lda #0
        sta vramRow
        ldx checkerModifier
        lda typeBBlankInitCountByHeightTable, x
        tax
        cpx #$C8 ; edge case for height 0
        bne @notZero
        ldx #$BE
@notZero:
        lda frameCounter
        and #1
        beq @checkerStartA
        lda #CHECKERBOARD_TILE
        bne @checkerStart
@checkerStartA:
        lda #EMPTY_TILE
@checkerStart:
        ; hydrantdude found the short way to do this
        ldy #$B
@loop:
        dey
        bne @notA
        eor #CHECKERBOARD_FLIP
        ldy #$A
@notA:  sta playfield, x
        eor #CHECKERBOARD_FLIP
        inx
        cpx #$C8
        bcc @loop
        rts

advanceGamePreset:
        jsr clearPlayfield
        ; render layout
        ldx #0
        stx generalCounter
@drawNext:
        ; get layout offset
        ldy presetModifier
        lda presets, y

        ; add index
        adc generalCounter

        ; load byte from layout
        tax
        ldy presets, x

        ; check if finished
        cpy #$FF
        beq @skip

        ; draw from y
        lda #$7B
        sta $0400, y

        ; loop
        inc generalCounter
        jmp @drawNext
@skip:
        rts


advanceGameTSpins:
        ; track the tspin quantity on the first tspin attempt
        lda tspinQuantity
        bne @qtyEnd
        lda tetriminoX
        cmp #$EF
        beq @qtyEnd
        lda statsByType
        sta tspinQuantity
@qtyEnd:
        ; reset score if tspinQuantity doesnt match
        lda score
        bne @scrub
        lda score+1
        bne @scrub
        lda score+2
        bne @scrub
        jmp @continue
@scrub:
        lda tspinQuantity
        beq @continue
        cmp statsByType
        beq @continue

        jsr clearPoints

        lda outOfDateRenderFlags
        ora #$04
        sta outOfDateRenderFlags
@continue:

advanceGameTSpins_actual:
        ; see if the sprite has reached the right position
        lda #8
        sbc tspinX
        cmp tetriminoX
        bne @notSuccessful
        lda #18
        sbc tspinY
        cmp tetriminoY
        bne @notSuccessful
        ; check the orientation
        lda currentPiece
        cmp #2
        bne @notSuccessful

        ; set successful tspin vars
        lda #$3
        sta playState
        lda #0
        sta tspinX
        sta vramRow ; shorter to do it here than in rendering

        ; add score
        lda #$2
        sta completedLines
        jsr addPointsRaw

        ; TODO: copy score to top
        lda #$20
        sta spawnDelay
        lda #TETRIMINO_X_HIDE
        sta tetriminoX

@notSuccessful:
        ; check if a tspin is setup
        lda tspinX
        cmp #0
        bne renderTSpin

generateNewTSpin:
        ldx #rng_seed
        ldy #$2
        jsr generateNextPseudorandomNumber
        lda rng_seed
        tax
        ; lower nybble
        and #$7
        sta tspinX
        ; high nybbleish
        txa
        ror
        ror
        ror
        ror
        and #3
        sta tspinY
        ; some other bit
        txa
        and #1
        sta tspinType

        lda #0
        sta tspinQuantity

renderTSpin:
        jsr clearPlayfield

        lda tspinY
        adc #1
        jsr drawFloor

        ; get tspin offset
        ldx tspinY
        lda multBy10Table, x
        sta tmp1

        lda #$FF
        sbc tspinX ; sub X
        sbc tmp1 ; sub Y
        tax
        ; draw tspin
        lda #EMPTY_TILE
        sta $03bc, x
        sta $03bd, x
        sta $03be, x
        sta $03c7, x
        sta $03b3, x
        ldy tspinType
        cpy #0
        bne @noInc
        inx
        inx
@noInc:
        sta $03b2, x

        rts

advanceGameFloor:
        lda floorModifier
drawFloor:
        ; get correct offset
        sta tmp1
        lda #$D
        sbc tmp1
        tax
        ; x10
        lda multBy10Table, x
        tax
        ; tile to draw is $7B
        lda #$7B
@loop:
        sta $0446,X
        inx
        cpx #$82
        bmi @loop
@skip:
        rts

advanceGameTap:
        jsr clearPlayfield
        ldx tapModifier
        cpx #0
        beq @skip ; skip if zero
        ldy #$BF ; left side
        cpx #$11
        bmi @loop
        ldy #$C6 ; right side
        txa
        sbc #$10
        tax

@loop:
        lda #$7B
        sta $400, y
        ; add 10 to y
        tya
        sec ;important
        sbc #$A
        tay
        dex
        bne @loop
@skip:
        rts

prepareNextParity:
        ; stacking highlights

        ; 1 red 1+ white
        ;   skip the first one
        ; 1 gap inbetween make the others red
        ; gap between wall and stack (left only)
        ; overhangs

        ldx #$7C
        lda levelNumber
        cmp #19
        bne @altColor
        inx
@altColor:
        stx parityColor

        ; change everything to 7B
        ldx #$C8
        lda #$7B
@loop:
        ldy playfield, x
        cpy #EMPTY_TILE
        beq @empty
        sta playfield, x
@empty:
        dex
        bne @loop

        ; mark things with parityColor

        lda #190
        sta parityIndex
@runLine:
        jsr highlightParity
        lda parityIndex
        sec
        sbc #10
        sta parityIndex
        cmp #30
        bcs @runLine
        rts

highlightParity:
        jsr highlightOrphans
        jsr highlightGaps
        rts

highlightGaps:
        ldx parityIndex

highlistGapsLeft:
        ; check first gap
        lda playfield, x
        cmp #EMPTY_TILE
        bne @startGapEnd
        lda playfield+1, x
        cmp #EMPTY_TILE
        beq @startGapEnd
        lda parityColor
        sta playfield+1, x
@startGapEnd:

highlightGapsOverhang:
        ldy #10

@checkHang:
        lda playfield, x
        cmp #EMPTY_TILE
        bne @checkGroup
        lda playfield-10, x
        cmp #EMPTY_TILE
        beq @checkGroup

        ; draw in red
        lda parityColor
        sta playfield-10, x

@checkGroup:
        cpy #3 ; you want the first 8
        bmi @groupNext
        ; horizontal
        lda playfield, x
        cmp #EMPTY_TILE
        beq @groupNext
        lda playfield+1, x
        cmp #EMPTY_TILE
        bne @groupNext
        lda playfield+2, x
        cmp #EMPTY_TILE
        beq @groupNext

        ; draw in red
        lda parityColor
        sta playfield, x
        sta playfield+2, x

@groupNext:
        inx
        dey
        bne @checkHang

        rts

highlightOrphans:
        ldx parityIndex
        ; reset stuff
        lda #0
        sta parityCount
        ldy #10

@checkString:
        lda playfield, x
        cmp #EMPTY_TILE
        beq @stringEmpty
        inc parityCount
        jmp @stringNext
@stringEmpty:
        lda parityCount
        cmp #1
        bne @resetCount
        ; dont highlight the first one
        cpy #9
        beq @resetCount
        ; last is skipped anyway
        lda parityColor
        sta playfield-1, x

@resetCount:
        lda #0
        sta parityCount
        jmp @stringNext

@stringNext:
        inx
        dey
        bne @checkString
        rts


prepareNextGarbage:
        lda garbageModifier
        jsr switch_s_plus_2a
        .addr garbageAlwaysTetrisReady
        .addr garbageNormal
        .addr garbageSmart
        .addr garbageHard
        .addr garbageTypeC ; infinite dig

garbageTypeC:
        jsr findTopBulky
        adc #$20 ; offset from starting position
@loop:
        sta tmp3

        jsr random10
        adc tmp3
        tax
        jsr swapMino
        txa

        sta tmp3
        cmp #$c0
        bcc @loop
        rts

findTopBulky:
        lda #$0
@loop:
        sta tmp3 ; line

        tax
        lda #0
        sta tmp2 ; line block qty
        ldy #9
@loopLine:
        lda playfield, x
        cmp #EMPTY_TILE
        beq @noBlock
        inc tmp2
@noBlock:
        inx
        dey
        bne @loopLine
        lda tmp2
        cmp #4 ; requirement
        bpl @done

        lda tmp3
        adc #$A
        cmp #$b8
        bcc @loop
@done:
        txa
        rts

swapMino:
        ldy #EMPTY_TILE
        lda playfield, x
        cmp #EMPTY_TILE
        bne @full
        ldy #BLOCK_TILES+3
@full:
        tya
        sta playfield, x
        rts

garbageNormal:
        jsr randomHole
        jsr randomGarbage
        rts

garbageSmart:
        jsr smartHole
        jsr randomGarbage
        rts

findTop:
        ldx #$0
@loop:
        lda playfield, x
        cmp #EMPTY_TILE
        bne @done
        inx
        cpx #$b8
        bcc @loop
@done:
        rts

randomGarbage:
        jsr findTop
        cpx #130
        bcc @done

        lda garbageDelay
        cmp #0
        bne @delay

        jsr random10
        and #3
        sta pendingGarbage
        jsr random10
        and #$7
        adc #$2+1
        sta garbageDelay
@delay:
        dec garbageDelay
@done:
        rts

garbageHard:
        jsr findTop
        cpx #100
        bcc @nothing

        lda spawnCount
        and #1
        bne @nothing
        jsr randomHole
        inc pendingGarbage
@nothing:
        rts

smartHole:
        ldx #199
@loop:
        lda playfield, x
        cmp #EMPTY_TILE
        beq @done
        dex
        cpx #190
        bcs @loop
@done:
        txa
        sbc #190
        sta garbageHole
        rts

randomHole:
        jsr random10
        sta garbageHole
        rts

random10:
        ldx #rng_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        ldx #rng_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        ldx #rng_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        ldx #rng_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        ldx #rng_seed
        ldy #$02
        jsr generateNextPseudorandomNumber
        lda rng_seed
        and #$0F
        cmp #$0A
        bpl random10
        rts

garbageAlwaysTetrisReady:
        ; right well
        lda #9
        sta garbageHole

        lda #0
        sta tmp1 ; garbage to add

        ldx #190
        jsr checkTetrisReady
        ldx #180
        jsr checkTetrisReady
        ldx #170
        jsr checkTetrisReady
        ldx #160
        jsr checkTetrisReady

        lda tmp1
        sta pendingGarbage
        rts

checkTetrisReady:
        ldy #9
@loop:
        lda playfield, x
        cmp #EMPTY_TILE
        bne @filled
        inc tmp1 ; add garbage
        ldy #1
@filled:
        inx
        dey
        bne @loop
        rts

.endif


; End of "PRG_chunk2" segment
.code


.segment    "PRG_chunk3": absolute

; incremented to reset MMC1 reg
reset:  cld
        sei
        ldx #$00
        stx PPUCTRL
        stx PPUMASK
@vsyncWait1:
        lda PPUSTATUS
        bpl @vsyncWait1
@vsyncWait2:
        lda PPUSTATUS
        bpl @vsyncWait2
        dex
        txs
        inc reset
        lda #$10
        jsr setMMC1Control
        lda #$00
        jsr changeCHRBank0
        lda #$00
        jsr changeCHRBank1
        lda #$00
        jsr changePRGBank
        jmp initRam

MMC1_PRG:
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $00
        .byte   $00

; End of "PRG_chunk3" segment
.code


.segment    "VECTORS": absolute

        .addr   nmi
        .addr   reset
        .addr   irq

; End of "VECTORS" segment
.code