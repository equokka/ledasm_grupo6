                    title   AC Projeto Prático - Grupo 6
                            ; O grupo 6 é constituído por:
                            ; * Daniel Conceição
                            ; * Filipe Correia
                            ; * Pedro Filipe

; Objetivos:
; * Dado um conjunto de oito lâmpadas (leds, sinais luminosos), numeradas de 0 a
;   7, permitir a escolha de várias  alternativas de padrões (combinações) de
;   luzes coloridas:
;   * todas desligada (apagadas);                                               [x]
;   * todas acesas (ligadas);                                                   [x]
;   * em alternância: ligadas (0, 2, 4, 6), desligadas (1, 3, 5, 7);            [x]
; * Definir a cor da luz, a posição (linha e coluna) das lâmpadas e a dimensão
;   (um ou mais caracteres).                                                    [x]

; Requisitos:
; * Estruturar o programa usando procedimentos (nomeadamente para a entrada dos
;   dados), variáveis (incluindo vetores, se adequado) e constantes.            [x]
; * Incluir um "menu" inicial que permita a escolher a operação a executar.     [x]
; * Prevenir e detetar a ocorrência de erros na leitura dos dados (validação).  [x]
; * Documentar devidamente o código, acrescentando comentários ao programa
;   fonte, ou em documento separado, indicando:
;   * Procedimentos definidos e forma de passagem de parâmetros;                [x]
;   * Algoritmo(s) implementado(s);                                             [x]
;   * Limitações do programa (valores das variáveis) e situações não
;     contempladas.                                                             [x]
;   * Atender a questões de eficiência: minimizar o nº de instruções e o nº de
;     variáveis (memória ocupada)                                               [x]
;
; ---
;
; * Entrega intermédia: estrutura do programa, ecrã inicial e variáveis e
;   procedimentos a definir.                                                    [x]
; * Apresentação oral e demonstração.                                           [ ]

; --------------------------------------------------------------------------------------------------------------------------------------------------------------

                    org     100h
                    jmp     main

; LED arrays
led_asize           db      8
led_x               db      1,4,7,10,13,16,19,22
led_y               db      1,2,1,2,1,2,1,2
led_state           db      8 dup (1)
led_size            db      8 dup (2)
led_color           db      8 dup (0Fh) ; bright white

;  01234567890123456789012345
; 0 xx    xx    xx    xx
; 1 xx xx xx xx xx xx xx xx
; 2    xx    xx    xx    xx

; Côr para LEDs desligados
led_color_disabled  db      08h ; gray

; Strings
txt_colors          db      " ________________________________ ", 0ah,0dh
                    db      "| 0 Black       | 8 Gray         |", 0ah,0dh
                    db      "| 1 Blue        | 9 Light Blue   |", 0ah,0dh
                    db      "| 2 Green       | A Light Green  |", 0ah,0dh
                    db      "| 3 Aqua        | B Light Aqua   |", 0ah,0dh
                    db      "| 4 Red         | C Light Red    |", 0ah,0dh
                    db      "| 5 Purple      | D Light Purple |", 0ah,0dh
                    db      "| 6 Yellow      | E Light Yellow |", 0ah,0dh
                    db      "| 7 White       | F Bright White |", 0ah,0dh
                    db      " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ", 0ah,0dh,24h

txt_menu_0          db      " ::: ledasm_grupo6 :::            ", 0ah,0dh
                    db      " 0 - Desligar                     ", 0ah,0dh
                    db      " 1 - Selecionar padrão            ", 0ah,0dh
                    db      " 2 - Alterar LEDs                 ", 0ah,0dh
                    db      " 3 - Visualizar LEDs              ", 0ah,0dh,24h

txt_menu_1          db      " ::: Selecionar padrão :::        ", 0ah,0dh
                    db      " 0 - Voltar a trás                ", 0ah,0dh
                    db      " 1 - Todos desligados             ", 0ah,0dh
                    db      " 2 - Todos ligados                ", 0ah,0dh
                    db      " 3 - Alternados                   ", 0ah,0dh
                    db      " 4 - Alternados (alt)             ", 0ah,0dh,24h

txt_menu_2          db      " ::: Alterar LEDs :::             ", 0ah,0dh
                    db      " 0 - Voltar a trás                ", 0ah,0dh
                    db      " 1 - Alterar todos                ", 0ah,0dh
                    db      " 2 - Alterar LED específico       ", 0ah,0dh,24h

txt_menu_2_1        db      " ::: Alterar LEDs :::             ", 0ah,0dh
                    db      " 0 - Voltar a trás                ", 0ah,0dh
                    db      " 1 - Cor                          ", 0ah,0dh
                    db      " 2 - Posição X                    ", 0ah,0dh
                    db      " 3 - Posição Y                    ", 0ah,0dh
                    db      " 4 - Dimensão                     ", 0ah,0dh,24h

txt_option          db      " Opção: ", 24h

txt_pick_led        db      " LED # (1-8): ", 24h
txt_pick_color      db      " Côr: ", 24h
txt_pick_pos_x      db      " Posição X: ", 24h
txt_pick_pos_y      db      " Posição Y: ", 24h
txt_pick_size       db      " Dimensão (1-5): ", 24h

txt_pos_warning     db      " Atenção: Posições fora da janela não serão"
                    db      " visíveis.", 0ah,0dh,24h

txt_newline         db      0ah,0dh,24h
txt_clear_screen    db      30 dup(0ah,0dh), 24h                                ; literally just 30 newlines

; Procedures ---------------------------------------------------------------------------------------------------------------------------------------------------

; shorthand for int 21h/09h: Main DOS API/Display String.
; requires a terminated string loaded into `dx`.
print               proc
                    push    ax                                                  ; store `ax` in the stack
                    mov     ah, 09h                                             ; print string with int 21h/09h
                    int     21h
                    pop     ax                                                  ; restore `ax` from the stack
                    ret                                                         ; return
print               endp

; converts ascii on `al` to decimal
convert_ascii_dec   proc
                    sub     al, 48
                    ret
convert_ascii_dec   endp

; converts ascii on `al` to hexadecimal
; using this method https://stackoverflow.com/a/34692373/12086004
convert_ascii_hex   proc
                    cmp     al, 39h                                             ; is `al` > 39 ?
                    jle     conv_ascii_hex
                    sub     al, 07h                                             ; if it is, subtract by 7
  conv_ascii_hex:
                    and     al, 0fh                                             ; al <- (al AND 0fh) to get 0 to F hexadecimal
                    ret
convert_ascii_hex   endp

; gets one character, stores it in `al`
get_char            proc
                    push    bx
                    push    ax

                    mov     ah, 01h                                             ; INT 21h/AH=1 - read character from standard input, with echo, result in `al`.
                    int     21h

                    mov     bl, al                                              ; bl <- al
                    pop     ax                                                  ; restore original `ax`
                    mov     al, bl                                              ; al <- bl
                    pop     bx                                                  ; restore original `bx`

                    ret
get_char            endp

; prints txt_option and then receives an option 0-`al` where `al` is 1-9
; if the value given is not valid, this repeats.
; result stored in `al`.
get_option          proc
                    push    bx
                    mov     bl, al                                              ; `bl` <- `al` (0-bl options)
                    push    ax
  get_option_init:
                    lea     dx, txt_option                                      ; print txt_option
                    call    print

                    call    get_char                                            ; get one character, store in `al`

                    lea     dx, txt_newline                                     ; print a newline
                    call    print

                    call    convert_ascii_dec                                   ; convert character in `al` to decimal

                    cmp     al, 0                                               ; if 0 >= `al` >= `bl` is not true then jump back to the start
                    jl      get_option_init
                    cmp     al, bl
                    jg      get_option_init

                    mov     bl, al                                              ; `bl` <- `al` (option number)
                    pop     ax                                                  ; restore original `ax`
                    mov     al, bl                                              ; `al` <- `bl`
                    pop     bx                                                  ; restore original `bx`

                    ret
get_option          endp

; gets two characters, interprets and converts them to decimal, and stores the result in `al`.
; if the input is not valid, `al` = 100
get_dec_2           proc
                    push    bx
                    push    ax

                    call    get_char                                            ; get char, store in `al`

                    cmp     al, 13                                              ; is `al` cret / Enter?
                    je      get_dec_2_err                                       ; if so, error out


                    call    convert_ascii_dec                                   ; convert to decimal
                    cmp     al, 0                                               ; if 0 <= `al` <= 9 isn't true, error out
                    jl      get_dec_2_err
                    cmp     al, 9
                    jg      get_dec_2_err

                    mov     bl, al                                              ; `bl` <- `al` : store 1st num in `bl`

                    call    get_char                                            ; get another char

                    cmp     al, 13                                              ; is `al` cret / Enter?
                    je      get_dec_2_ok                                        ; if so, skip multiplying the first number by 10

                    call    convert_ascii_dec                                   ; convert to decimal
                    cmp     al, 0                                               ; if 0 <= `al` <= 9 isn't true, error out
                    jl      get_dec_2_err
                    cmp     al, 9
                    jg      get_dec_2_err

                    mov     bh, al                                              ; `bh` <- `al` : store 2nd num in `bh`
                    mov     al, bl                                              ; `al` <- `bl` : store 1st num in `al`
                    mov     bl, 10                                              ; `bl` <- 10
                    mul     bl                                                  ; `al` <- `al` * `bl` : multiply 1st num by 10
                    add     al, bh                                              ; `al` <- `al` + `bh` : add 1st num and 2nd num

                    mov     bl, al                                              ; `bl` <- `al`

                    lea     dx, txt_newline                                         ; print a newline
                    call    print

                    jmp     get_dec_2_ok
  get_dec_2_err:
                    mov     bl, 100                                             ; `bl` <- 100 : set the return value to 100, to mean that the value is invalid.
                    lea     dx, txt_newline                                         ; print a newline
                    call    print
  get_dec_2_ok:
                    pop     ax                                                  ; restore original `ax`
                    mov     al, bl                                              ; `al` <- `bl`
                    pop     bx                                                  ; restore original `bx`

                    ret
get_dec_2           endp

clear_screen        proc
                    push    dx
                    lea     dx, txt_clear_screen
                    call    print
                    pop     dx
                    ret
clear_screen        endp

; wait for a single key press before continuing
wait_for_input      proc
                    push    ax
                    mov     ah, 07h                                             ; int 21h/ah=08h - No Echo Console Input
                    int     21h                                                 ; https://dos4gw.org/DOS_Fn_08H_No_Echo_Console_Input
                    pop     ax
                    ret
wait_for_input      endp

; Procedures -- Drawing ----------------------------------------------------------------------------------------------------------------------------------------

; Draw one character at (`dl`, `dh`) with color `cl`
draw                proc
                    push    ax
                    push    si
                    push    bx

                    mov     bh, 0                                               ; BH = Page Number

                    mov     ah, 02h                                             ; int 10h/ah=02h - Set Cursor Position
                    int     10h                                                 ; https://dos4gw.org/INT_10h_02h_2_Set_Cursor_Position

                    mov     bl, cl                                              ; `bl` <- `cl` : pass color in `cl` to `bl` which is used by int 10h/ah=09h
                    shl     bl, 4                                               ; shift `bl` to the left 4 bits, ie 0444 -> 0444 0000
                    add     bl, cl                                              ; add `cl` ie 0444 0000 -> 0444 0444. this way bg = fg color

                    push    cx                                                  ; store original `cx`

                    mov     al, " "
                    mov     cx, 1                                               ; Number of times to print character

                    mov     ah, 09h                                             ; int 10h/ah=09h - Write Character and Attribute at Cursor
                    int     10h                                                 ; https://dos4gw.org/INT_10h_09h_9_Write_Character_and_Attribute_at_Cursor

                    pop     cx
                    pop     bx
                    pop     si
                    pop     ax

                    ret
draw                endp

; Draw LED with index `al`. Size, position, color are fetched from variables
draw_led            proc
                    push    bx
                    push    dx
                    push    cx
                    mov     bl, al                                              ; `bx` <- `al`
                    push    ax

                    mov     dl, led_x[bx]                                       ; `dl` <- led_x[`bx`]     - Pos X
                    mov     dh, led_y[bx]                                       ; `dh` <- led_y[`bx`]     - Pos Y
                    mov     ch, led_size[bx]                                    ; `ch` <- led_size[`bx`]  - Size
                    mov     cl, led_color[bx]                                   ; `cl` <- led_color[`bx`] - Color
                    mov     ah, led_state[bx]                                   ; `ah` <- led_state[`bx`] - Enabled?
                    cmp     ah, 0                                               ; If it's disabled we set the color to the preset disabled color
                    jne     draw_led_enabled
                    mov     cl, led_color_disabled                              ; `cl` <- led_color_disabled
  draw_led_enabled:
                    cmp     ch, 1                                               ; If size is 1 then just draw once and exit
                    jne     draw_led_not1
                    call    draw
                    jmp     draw_led_done
  draw_led_not1:
                    mov     ah, ch                                              ; `al` <- `ch` : Y loop counter
  draw_led_ly:
                    mov     al, ch                                              ; `al` <- `ch` : X loop counter
    draw_led_lx:
                    mov     dl, led_x[bx]                                       ; `dl` <- led_x[`bx`] + al : Pos X
                    add     dl, al
                    mov     dh, led_y[bx]                                       ; `dh` <- led_y[`bx`] + ah : Pos Y
                    add     dh, ah
                    call    draw                                                ; draw at new position

                    dec     al
                    cmp     al, 0
                    jne     draw_led_lx
   ;draw_led_lx     /-----------------------------------------------------------
                    dec     ah
                    cmp     ah, 0
                    jne     draw_led_ly
 ;draw_led_y        /-----------------------------------------------------------

  draw_led_done:
                    pop     ax
                    pop     cx
                    pop     dx
                    pop     bx
                    ret
draw_led            endp

; Draws all the LEDs.
draw_all_leds       proc
                    push    ax
                    mov     al, 0
  draw_all_leds_l:
                    call    draw_led
                    inc     al
                    cmp     al, led_asize
                    jl      draw_all_leds_l
                    pop     ax
                    ret
draw_all_leds       endp

; Main procedure -----------------------------------------------------------------------------------------------------------------------------------------------

main                proc

  menu_0: ; -------------------------------------------------------------------- MENU 0 - Menu principal -------------------------------------------------------
                    call    clear_screen
                    lea     dx, txt_menu_0
                    call    print
                    mov     al, 3
                    call    get_option

                    cmp     al, 0                                               ; 0 -> Sair do programa
                    je      exit
                    cmp     al, 1                                               ; 1 -> Ir para o menu 1 (Selecionar padrão)
                    je      menu_1
                    cmp     al, 2                                               ; 2 -> Ir para o menu 2 (Alterar LEDs)
                    je      menu_2
                    cmp     al, 3                                               ; 3 -> Visualizar leds
                    je      leds_view

  menu_1: ; -------------------------------------------------------------------- MENU 1 - Selecionar padrão ----------------------------------------------------
                    call    clear_screen
                    lea     dx, txt_menu_1
                    call    print
                    mov     al, 4
                    call    get_option

                    cmp     al, 0                                               ; 0 -> Ir para o menu 0
                    je      menu_0
                    cmp     al, 1                                               ; 1 -> Todos desligados
                    je      option_1_1
                    cmp     al, 2                                               ; 2 -> Todos ligados
                    je      option_1_2
                    cmp     al, 3                                               ; 3 -> Alternados
                    je      option_1_3
                    cmp     al, 4                                               ; 4 -> Alternados (alt)
                    je      option_1_4

  menu_2: ; -------------------------------------------------------------------- MENU 2 - Alterar LEDs ---------------------------------------------------------
                    call    clear_screen
                    lea     dx, txt_menu_2
                    call    print
                    mov     al, 2
                    call    get_option

                    mov     ah, al                                              ; `ah` <- `al` : store previous option in `ah`

                    cmp     al, 0                                               ; 0 -> Ir para o menu 0
                    je      menu_0
                    cmp     al, 1                                               ; 1 -> Alterar todos
                    je      menu_2_1
                    cmp     al, 2                                               ; 2 -> Alterar LED específico
                    je      option_2_2

  menu_2_1: ; ------------------------------------------------------------------ MENU 2_1 - Atributos do(s) LED(s) ---------------------------------------------
                    call    clear_screen
                    lea     dx, txt_menu_2_1
                    call    print

                    mov     al, 4
                    call    get_option

                    cmp     al, 0                                               ; 0 -> Ir para o menu 0
                    je      menu_0
                    cmp     al, 1                                               ; 1 -> Cor
                    je      option_2_1_1
                    cmp     al, 2                                               ; 2 -> Posição X
                    je      option_2_1_2
                    cmp     al, 3                                               ; 3 -> Posição Y
                    je      option_2_1_3
                    cmp     al, 4                                               ; 4 -> Dimensão
                    je      option_2_1_4

  option_1_1: ; ---------------------------------------------------------------- MENU 1, OPÇÃO 1 - Todos desligados --------------------------------------------
                    mov     bx, 0
    option_1_1_l:
                    mov     led_state[bx], 0

                    inc     bx
                    cmp     bl, led_asize
                    jl      option_1_1_l

                    jmp     leds_view
  option_1_2: ; ---------------------------------------------------------------- MENU 1, OPÇÃO 2 - Todos ligados -----------------------------------------------
                    mov     bx, 0
    option_1_2_l:
                    mov     led_state[bx], 1

                    inc     bx
                    cmp     bl, led_asize
                    jl      option_1_2_l

                    jmp     leds_view
  option_1_3: ; ---------------------------------------------------------------- MENU 1, OPÇÃO 3 - Alternados --------------------------------------------------
                    mov     bx, 0
    option_1_3_l:
                    test    bx, 1                                               ; what is the parity of `bx`? -- https://stackoverflow.com/a/49116885/12086004
                    jnz     option_1_3_o
                    jz      option_1_3_e
      option_1_3_o:                                                             ; `bl` odd
                    mov     led_state[bx], 0
                    jmp     option_1_3_n
      option_1_3_e:                                                             ; `bl` even
                    mov     led_state[bx], 1
                    jmp     option_1_3_n
      option_1_3_n:
                    inc     bx
                    cmp     bl, led_asize
                    jl      option_1_3_l

                    jmp     leds_view
  option_1_4: ; ---------------------------------------------------------------- MENU 1, OPÇÃO 4 - Alternados (alt) --------------------------------------------
                    mov     bx, 0
    option_1_4_l:
                    test    bl, 1                                               ; what is the parity of `bl`? -- https://stackoverflow.com/a/49116885/12086004
                    jnz     option_1_4_o
                    jz      option_1_4_e
      option_1_4_o:                                                             ; `bl` odd
                    mov     led_state[bx], 1
                    jmp     option_1_4_n
      option_1_4_e:                                                             ; `bl` even
                    mov     led_state[bx], 0
                    jmp     option_1_4_n
      option_1_4_n:
                    inc     bx
                    cmp     bl, led_asize
                    jl      option_1_4_l

                    jmp     leds_view

  option_2_2: ; ---------------------------------------------------------------- MENU 2, OPÇÃO 2 - Selecione um LED --------------------------------------------
                    lea     dx, txt_newline
                    call    print
                    lea     dx, txt_pick_led
                    call    print

                    call    get_char                                            ; get char, store in `al`
                    call    convert_ascii_dec                                   ; convert `al` to decimal
                    cmp     al, 1                                               ; 1 <= `al` <= 7, otherwise try again
                    jl      option_2_2
                    cmp     al, 8
                    jg      option_2_2

                    dec     al                                                  ; `al` <- `al` - 1 : because 0-index

                    mov     bl, al                                              ; `bx` <- `al` : store currently selected LED in bx

                    jmp     menu_2_1

  option_2_1_1: ; -------------------------------------------------------------- MENU 2_1, OPÇÃO 1 - Côr -------------------------------------------------------
                    call    clear_screen
                    lea     dx, txt_colors
                    call    print
    pick_color_init:
                    lea     dx, txt_newline
                    call    print
                    lea     dx, txt_pick_color
                    call    print

                    call    get_char                                            ; get character, store in `al`

                                                                                ; next we need to make sure the character is in one of these ranges:
                                                                                ; 48-57  - 0-9
                                                                                ; 65-70  - A-F
                                                                                ; 97-102 - a-f

                    cmp     al, 97                                              ; `al` >= 97?
                    jge     pick_color_rg3                                      ; move on to next check
                    cmp     al, 65                                              ; `al` >= 65?
                    jge     pick_color_rg2
                    cmp     al, 48                                              ; `al` >= 48?
                    jge     pick_color_rg1
                    jmp     pick_color_init                                     ; start over if none of these confirm

    pick_color_rg1:
                    cmp     al, 57                                              ; `al` >= 57?
                    jle     pick_color_ok                                       ; if so, move on to convert to hex
                    jmp     pick_color_init                                     ; otherwise start over
    pick_color_rg2:
                    cmp     al, 70                                              ; `al` >= 70?
                    jle     pick_color_ok
                    jmp     pick_color_init
    pick_color_rg3:
                    cmp     al, 102                                             ; `al` >= 102?
                    jle     pick_color_ok
                    jmp     pick_color_init
    pick_color_ok:
                    call    convert_ascii_hex                                   ; convert ascii in `al` to hex

                    cmp     ah, 1
                    je      pick_color_all
                    cmp     ah, 2
                    je      pick_color_one

    pick_color_one:
                    mov     led_color[bx], al
                    jmp     pick_color_exit
    pick_color_all:
                    mov     cl, 0
      pick_color_al:
                    mov     bl, cl
                    mov     led_color[bx], al

                    inc     cl
                    cmp     cl, led_asize
                    jl      pick_color_al
    pick_color_exit:
                    jmp     menu_2_1
  option_2_1_2: ; -------------------------------------------------------------- MENU 2_1, OPÇÃO 2 - Posição X -------------------------------------------------
                    lea     dx, txt_newline
                    call    print
                    lea     dx, txt_pos_warning
                    call    print
                    lea     dx, txt_pick_pos_x
                    call    print

                    call    get_dec_2                                           ; get a 2 digit decimal value
                    cmp     al, 100                                             ; if there's an error, start over
                    je      option_2_1_2

                    cmp     ah, 1
                    je      pick_pos_x_all
                    cmp     ah, 2
                    je      pick_pos_x_one

    pick_pos_x_one:
                    mov     led_x[bx], al
                    jmp     pick_pos_x_exit
    pick_pos_x_all:
                    mov     cl, 0
      pick_pos_x_al:
                    mov     bl, cl
                    mov     led_x[bx], al

                    inc     cl
                    cmp     cl, led_asize
                    jl      pick_pos_x_al
    pick_pos_x_exit:
                    jmp     menu_2_1
  option_2_1_3: ; -------------------------------------------------------------- MENU 2_1, OPÇÃO 3 - Posição Y -------------------------------------------------
                    lea     dx, txt_newline
                    call    print
                    lea     dx, txt_pos_warning
                    call    print
                    lea     dx, txt_pick_pos_y
                    call    print

                    call    get_dec_2                                           ; get a 2 digit decimal value
                    cmp     al, 100                                             ; if there's an error, start over
                    je      option_2_1_3

                    cmp     ah, 1
                    je      pick_pos_y_all
                    cmp     ah, 2
                    je      pick_pos_y_one

    pick_pos_y_one:
                    mov     led_y[bx], al
                    jmp     pick_pos_y_exit
    pick_pos_y_all:
                    mov     cl, 0
      pick_pos_y_al:
                    mov     bl, cl
                    mov     led_y[bx], al

                    inc     cl
                    cmp     cl, led_asize
                    jl      pick_pos_y_al
    pick_pos_y_exit:
                    jmp     menu_2_1
  option_2_1_4: ; -------------------------------------------------------------- MENU 2_1, OPÇÃO 4 - Dimensão --------------------------------------------------
                    lea     dx, txt_newline
                    call    print
                    lea     dx, txt_pick_size
                    call    print

                    call    get_char                                            ; get char, store in `al`
                    call    convert_ascii_dec                                   ; convert `al` to decimal

                    cmp     al, 1                                               ; 1 <= `al` <= 5, otherwise try again
                    jl      option_2_1_4
                    cmp     al, 5
                    jg      option_2_1_4

                    cmp     ah, 1
                    je      pick_size_all
                    cmp     ah, 2
                    je      pick_size_one

    pick_size_one:
                    mov     led_size[bx], al
                    jmp     pick_size_exit
    pick_size_all:
                    mov     cl, 0
      pick_size_al:
                    mov     bl, cl
                    mov     led_size[bx], al

                    inc     cl
                    cmp     cl, led_asize
                    jl      pick_size_al
    pick_size_exit:
                    jmp     menu_2_1

  leds_view: ; ----------------------------------------------------------------- MENU 0, OPÇÃO 3 - Visualizar LEDs ---------------------------------------------
                    call    clear_screen
                    call    draw_all_leds
                    call    wait_for_input
                    jmp     menu_0

; --------------------------------------------------------------------------------------------------------------------------------------------------------------
  exit:
                    call    clear_screen
                    int     20h                                                 ; end program
main                endp


