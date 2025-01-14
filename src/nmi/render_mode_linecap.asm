render_mode_linecap_menu:
        lda outOfDateRenderFlags
        and #1
        beq @static
        ; render level / lines
        lda #0
        sta outOfDateRenderFlags
        lda #$21
        sta PPUADDR
        lda #$F3
        sta PPUADDR
        jsr render_linecap_level_lines

@static:
        jmp render_mode_static

render_linecap_level_lines:
        lda linecapWhen
        bne @linecapLines
        lda linecapLevel
        jsr renderByteBCD
        jmp render_mode_static

@linecapLines:
        lda linecapLines+1
        sta PPUDATA
        lda linecapLines
        jsr twoDigsToPPU
        rts
