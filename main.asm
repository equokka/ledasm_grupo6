                    title   AC Projeto PrÃÂ¡tico - Grupo 6
                            ; O grupo 6 ÃÂ© constituÃÂ­do por:
                            ; * Daniel ConceiÃÂ§ÃÂ£o
                            ; * Filipe Correia
                            ; * Pedro Filipe

; Objetivos:
; * Dado um conjunto de oito lÃÂ¢mpadas (leds, sinais luminosos), numeradas de 0 a
;   7, permitir a escolha de vÃÂ¡rias  alternativas de padrÃÂµes (combinaÃÂ§ÃÂµes) de
;   luzes coloridas:
;   * todas desligada (apagadas);                                               [ ]
;   * todas acesas (ligadas);                                                   [ ]
;   * em alternÃÂ¢ncia: ligadas (0, 2, 4, 6), desligadas (1, 3, 5, 7);            [ ]
; * Definir a cor da luz, a posiÃÂ§ÃÂ£o (linha e coluna) das lÃÂ¢mpadas e a dimensÃÂ£o
;   (um ou mais caracteres).                                                    [ ]

; Requisitos:
; * Estruturar o programa usando procedimentos (nomeadamente para a entrada dos
;   dados), variÃÂ¡veis (incluindo vetores, se adequado) e constantes.            [ ]
; * Incluir um "menu" inicial que permita a escolher a operaÃÂ§ÃÂ£o a executar.     [ ]
; * Prevenir e detetar a ocorrÃÂªncia de erros na leitura dos dados (validaÃÂ§ÃÂ£o).  [ ]
; * Documentar devidamente o cÃÂ³digo, acrescentando comentÃÂ¡rios ao programa
;   fonte, ou em documento separado, indicando:
;   * Procedimentos definidos e forma de passagem de parÃÂ¢metros;                [ ]
;   * Algoritmo(s) implementado(s);                                             [ ]
;   * LimitaÃÂ§ÃÂµes do programa (valores das variÃÂ¡veis) e situaÃÂ§ÃÂµes nÃÂ£o
;     contempladas.                                                             [ ]
;   * Atender a questÃÂµes de eficiÃÂªncia: minimizar o nÃÂº de instruÃÂ§ÃÂµes e o nÃÂº de
;     variÃÂ¡veis (memÃÂ³ria ocupada)                                               [ ]
;
; ---
;
; * Entrega intermÃÂ©dia: estrutura do programa, ecrÃÂ£ inicial e variÃÂ¡veis e
;   procedimentos a definir.                                                    [x]
; * ApresentaÃÂ§ÃÂ£o oral e demonstraÃÂ§ÃÂ£o.                                           [ ]

; --------------------------------------------------------------------------------------------------------------------------------------------------------------

                    org     100h
                    jmp     main

; LED arrays
led_index           db      0                                                   ; index for iterating over LEDs
led_asize           db      8                                                   ; size of LED array
led_x               db      0,1,2,3,4,5,0,0 ; 8 dup (0)
led_y               db      0,1,2,3,4,5,0,0 ; 8 dup (0)
led_size            db      8 dup (1)
led_color           db      8 dup (0Fh) ; bright white

; CÃÂ´r para LEDs desligados
color_disabled      db      08h ; gray

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
                    db      " 1 - Selecionar padrÃÂ£o            ", 0ah,0dh
                    db      " 2 - Alterar LEDs                 ", 0ah,0dh
                    db      " 3 - Visualizar LEDs              ", 0ah,0dh,24h

txt_menu_1          db      " ::: Selecionar padrÃÂ£o :::        ", 0ah,0dh
                    db      " 0 - Voltar a trÃÂ¡s                ", 0ah,0dh
                    db      " 1 - Todos desligados             ", 0ah,0dh
                    db      " 2 - Todos ligados                ", 0ah,0dh
                    db      " 3 - Alternados                   ", 0ah,0dh
                    db      " 4 - Alternados (alt)             ", 0ah,0dh,24h

txt_menu_2          db      " ::: Alterar LEDs :::             ", 0ah,0dh
                    db      " 0 - Voltar a trÃÂ¡s                ", 0ah,0dh
                    db      " 1 - Alterar todos                ", 0ah,0dh
                    db      " 2 - Alterar LED especÃÂ­fico       ", 0ah,0dh,24h

txt_menu_2_1        db      " ::: Alterar LEDs :::             ", 0ah,0dh
                    db      " 0 - Voltar a trÃÂ¡s                ", 0ah,0dh
                    db      " 1 - Cor                          ", 0ah,0dh
                    db      " 2 - PosiÃÂ§ÃÂ£o X                    ", 0ah,0dh
                    db      " 3 - PosiÃÂ§ÃÂ£o Y                    ", 0ah,0dh
                    db      " 4 - DimensÃÂ£o                     ", 0ah,0dh,24h

txt_option          db      " OpÃÂ§ÃÂ£o: ", 24h

txt_pick_led        db      " LED # (1-8): ", 24h
txt_pick_color      db      " CÃÂ´r: ", 24h
txt_pick_pos_x      db      " PosiÃÂ§ÃÂ£o X: ", 24h
txt_pick_pos_y      db      " PosiÃÂ§ÃÂ£o Y: ", 24h
txt_pick_size       db      " DimensÃÂ£o: ", 24h

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

; FIXME

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
                    cmp     al, 1                                               ; 1 -> Ir para o menu 1 (Selecionar padrÃÂ£o)
                    je      menu_1
                    cmp     al, 2                                               ; 2 -> Ir para o menu 2 (Alterar LEDs)
                    je      menu_2
                    cmp     al, 3                                               ; 3 -> Visualizar leds
                    je      leds_view

  menu_1: ; -------------------------------------------------------------------- MENU 1 - Selecionar padrÃÂ£o ----------------------------------------------------
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

                    cmp     al, 0                                               ; 0 -> Ir para o menu 0
                    je      menu_0
                    cmp     al, 1                                               ; 1 -> Alterar todos
                    je      menu_2_1
                    cmp     al, 2                                               ; 2 -> Alterar LED especÃÂ­fico
                    je      menu_2_2

  menu_2_1: ; ------------------------------------------------------------------ MENU 2_1 - Atributos do(s) LED(s) ---------------------------------------------
                    call    clear_screen
                    lea     dx, txt_menu_2_1
                    call    print

                    mov     ah, al                                              ; `ah` <- `al` : store previous option in `ah`

                    mov     al, 4
                    call    get_option

                    cmp     al, 0                                               ; 0 -> Ir para o menu 0
                    je      menu_0
                    cmp     al, 1                                               ; 1 -> Cor
                    je      option_2_1_1
                    cmp     al, 2                                               ; 2 -> PosiÃÂ§ÃÂ£o X
                    je      option_2_1_2
                    cmp     al, 3                                               ; 3 -> PosiÃÂ§ÃÂ£o Y
                    je      option_2_1_3
                    cmp     al, 4                                               ; 4 -> DimensÃÂ£o
                    je      option_2_1_4

  menu_2_2: ; ------------------------------------------------------------------ MENU 2_2 - Selecione um LED ---------------------------------------------------
                    ; FIXME
                    jmp     menu_2_1

  option_1_1: ; ---------------------------------------------------------------- MENU 1, OPÃÂÃÂO 1 - Todos desligados --------------------------------------------
                    ; FIXME
                    jmp     menu_0
  option_1_2: ; ---------------------------------------------------------------- MENU 1, OPÃÂÃÂO 2 - Todos ligados -----------------------------------------------
                    ; FIXME
                    jmp     menu_0
  option_1_3: ; ---------------------------------------------------------------- MENU 1, OPÃÂÃÂO 3 - Alternados --------------------------------------------------
                    ; FIXME
                    jmp     menu_0
  option_1_4: ; ---------------------------------------------------------------- MENU 1, OPÃÂÃÂO 4 - Alternados (alt) --------------------------------------------
                    ; FIXME
                    jmp     menu_0

  option_2_1_1: ; -------------------------------------------------------------- MENU 2_1, OPÃÂÃÂO 1 - CÃÂ´r -------------------------------------------------------
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
                    je      pick_color_one
                    cmp     ah, 2
                    je      pick_color_all

    pick_color_one:
                    ;FIXME change color in the selected LED
                    jmp     pick_color_exit
    pick_color_all:
                    ;FIXME change color in all LEDs
                    jmp     pick_color_exit

    pick_color_exit:
                    jmp     menu_2_1
  option_2_1_2: ; -------------------------------------------------------------- MENU 2_1, OPÃÂÃÂO 2 - PosiÃÂ§ÃÂ£o X -------------------------------------------------
                    lea     dx, txt_newline
                    call    print
                    lea     dx, txt_pick_pos_x
                    call    print

                    call    get_dec_2                                           ; get a 2 digit decimal value
                    cmp     al, 100                                             ; if there's an error, start over
                    je      option_2_1_2

                    cmp     ah, 1
                    je      pick_color_one
                    cmp     ah, 2
                    je      pick_color_all

    pick_pos_x_one:
                    ;FIXME change in selected led
                    jmp     pick_pos_x_exit
    pick_pos_x_all:
                    ;FIXME change in all leds
                    jmp     pick_pos_x_exit

    pick_pos_x_exit:
                    jmp     menu_2_1
  option_2_1_3: ; -------------------------------------------------------------- MENU 2_1, OPÃÂÃÂO 3 - PosiÃÂ§ÃÂ£o Y -------------------------------------------------
                    lea     dx, txt_newline
                    call    print
                    lea     dx, txt_pick_pos_y
                    call    print

                    call    get_dec_2                                           ; get a 2 digit decimal value
                    cmp     al, 100                                             ; if there's an error, start over
                    je      option_2_1_3

                    cmp     ah, 1
                    je      pick_pos_x_one
                    cmp     ah, 2
                    je      pick_pos_x_all

    pick_pos_y_one:
                    ;FIXME change in selected led
                    jmp     pick_pos_y_exit
    pick_pos_y_all:
                    ;FIXME change in all leds
                    jmp     pick_pos_y_exit

    pick_pos_y_exit:
                    jmp     menu_2_1
  option_2_1_4: ; -------------------------------------------------------------- MENU 2_1, OPÃÂÃÂO 4 - DimensÃÂ£o --------------------------------------------------
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
                    je      pick_size_one
                    cmp     ah, 2
                    je      pick_size_all

    pick_size_one:
                    ;FIXME change in selected led
                    jmp     pick_size_exit
    pick_size_all:
                    ;FIXME change in all leds
                    jmp     pick_size_exit

    pick_size_exit:
                    jmp     menu_2_1

  leds_view: ; ----------------------------------------------------------------- MENU 0, OPÃÂÃÂO 3 - Visualizar LEDs ---------------------------------------------
                    ; FIXME
                    call    clear_screen
                    lea     dx, txt_colors
                    call    print
                    call    wait_for_input
                    jmp     menu_0

; --------------------------------------------------------------------------------------------------------------------------------------------------------------
  exit:
                    call    clear_screen
                    int     20h                                                 ; end program
main                endp
