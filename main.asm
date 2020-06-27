                    title   AC Projeto Prático - Grupo 6
                            ; O grupo 6 é constituído por:
                            ; * Daniel Conceição
                            ; * Filipe Correia
                            ; * Pedro Filipe

; Objetivos:
; * Dado um conjunto de oito lâmpadas (leds, sinais luminosos), numeradas de 0 a
;   7, permitir a escolha de várias  alternativas de padrões (combinações) de
;   luzes coloridas:
;   * todas desligada (apagadas);                                               [ ]
;   * todas acesas (ligadas);                                                   [ ]
;   * em alternância: ligadas (0, 2, 4, 6), desligadas (1, 3, 5, 7);            [ ]
; * Definir a cor da luz, a posição (linha e coluna) das lâmpadas e a dimensão
;   (um ou mais caracteres).                                                    [ ]

; Requisitos:
; * Estruturar o programa usando procedimentos (nomeadamente para a entrada dos
;   dados), variáveis (incluindo vetores, se adequado) e constantes.            [ ]
; * Incluir um "menu" inicial que permita a escolher a operação a executar.     [ ]
; * Prevenir e detetar a ocorrência de erros na leitura dos dados (validação).  [ ]
; * Documentar devidamente o código, acrescentando comentários ao programa
;   fonte, ou em documento separado, indicando:
;   * Procedimentos definidos e forma de passagem de parâmetros;                [ ]
;   * Algoritmo(s) implementado(s);                                             [ ]
;   * Limitações do programa (valores das variáveis) e situações não
;     contempladas.                                                             [ ]
;   * Atender a questões de eficiência: minimizar o nº de instruções e o nº de
;     variáveis (memória ocupada)                                               [ ]
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
led_index           db      0                                                   ; index for iterating over LEDs
led_asize           db      8                                                   ; size of LED array
led_x               db      0,1,2,3,4,5,0,0 ; 8 dup (0)
led_y               db      0,1,2,3,4,5,0,0 ; 8 dup (0)
led_size            db      8 dup (1)
led_color           db      8 dup (0Fh) ; bright white

; C?r para LEDs desligados
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

txt_menu_0          db      " 0 - Desligar                     ", 0ah,0dh
                    db      " 1 - Selecionar padrão            ", 0ah,0dh
                    db      " 2 - Alterar LEDs                 ", 0ah,0dh,24h

txt_menu_1          db      " 0 - Voltar a trás                ", 0ah,0dh
                    db      " 1 - Todos desligados             ", 0ah,0dh
                    db      " 2 - Todos ligados                ", 0ah,0dh
                    db      " 3 - Alternados                   ", 0ah,0dh
                    db      " 4 - Alternados (alt)             ", 0ah,0dh,24h

txt_menu_2          db      " 0 - Voltar a trás                ", 0ah,0dh
                    db      " 1 - Alterar todos                ", 0ah,0dh
                    db      " 2 - Alterar LED especÃ­fico       ", 0ah,0dh,24h

txt_menu_2_a        db      " 0 - Voltar a trás                ", 0ah,0dh
                    db      " 1 - Cor                          ", 0ah,0dh
                    db      " 2 - Posição X                    ", 0ah,0dh
                    db      " 3 - Posição Y                    ", 0ah,0dh
                    db      " 4 - Dimensão                     ", 0ah,0dh,24h

txt_option          db      " Opção>", 24h

txt_pick_color      db      " Cor:       ", 24h
txt_pick_pos_x      db      " Posição X: ", 24h
txt_pick_pos_y      db      " Posição Y: ", 24h
txt_pick_size       db      " Dimensão:  ", 24h

txt_newline         db      0ah,0dh,24h
txt_clear_screen    db      30 dup(0ah,0dh), 24h                                ; literally just 30 newlines

; Procedures ---------------------------------------------------------------------------------------------------------------------------------------------------

; shorthand for int 21h/09h: Main DOS API/Display String.
; requires a terminated string loaded into `dx`.
print               proc
                    push    ax                                                  ; store ax in the stack
                    mov     ah, 09h                                             ; print string with int 21h/09h
                    int     21h
                    pop     ax                                                  ; restore ax from the stack
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
                    pop     ax                                                  ; restore original ax
                    mov     al, bl                                              ; al <- bl
                    pop     bx                                                  ; restore original bx

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

                    cmp     al, 0                                               ; if 0 >= `al` >= `bl` then jump back to the start
                    jl      get_option_init
                    cmp     al, bl
                    jg      get_option_init

                    mov     bl, al                                              ; `bl` <- `al` (option number)
                    pop     ax                                                  ; restore original ax
                    mov     al, bl                                              ; `al` <- `bl`
                    pop     bx                                                  ; restore original bx

                    ret
get_option          endp

clear_screen        proc
                    push    dx
                    lea     dx, txt_clear_screen
                    call    print
                    pop     dx
                    ret
clear_screen        endp

; Procedures -- Drawing ----------------------------------------------------------------------------------------------------------------------------------------

leds                proc

                    mov     ah, 09h

                    mov     al, led_index
  leds_loop:
                    call    led_draw

                    inc     al

                    cmp     al, led_asize
                    jne     leds_loop

                    ret
leds                endp

; draws the LED, index `al`
led_draw            proc
                    push    dx
                    push    bx

                    mov     bh, 0                                               ; BH | page number (0..7)

                    mov     dl, led_x                                           ; DH | row
                    add     dl, al
                    mov     dh, led_y                                           ; DL | column
                    add     dh, al

                    mov     ah, 02h                                             ; int 10h/02h
                    int     10h

                    mov     bl, led_size
                    add     bl, al

                    push    ax

                    mov     cl, bl
                    mov     ch, bl
  led_draw_h:
    led_draw_w:
                    mov     al, "#"
                    mov     ah, 02h
                    int     21h

                    dec     cl
                    cmp     cl, 0
                    jnz     led_draw_w
    ;led_draw_w
                    dec     ch
                    cmp     ch, 0
                    jnz     led_draw_ex

                    mov     ah, 03h
                    int     10h

                    inc     dh
                    sub     dl, bl

                    mov     ah, 02h
                    int     10h

                    jmp     led_draw_h
  ;led_draw_h

  led_draw_ex:

                    pop     ax

                    pop     bx
                    pop     dx
                    ret
led_draw            endp

; Main procedure -----------------------------------------------------------------------------------------------------------------------------------------------

main                proc

  menu_0:
                    call    clear_screen                                        ; MENU 0 -----------------------------------------------------------------------
                    lea     dx, txt_menu_0
                    call    print
                    mov     al, 2
                    call    get_option

                    cmp     al, 0                                               ; 0 -> Sair do programa
                    je      exit
                    cmp     al, 1                                               ; 1 -> Ir para o menu 1
                    je      menu_1
                    cmp     al, 2                                               ; 2 -> Ir para o menu 2
                    je      menu_2
  menu_1:
                    call    clear_screen                                        ; MENU 1 -----------------------------------------------------------------------
                    lea     dx, txt_menu_1
                    call    print
                    mov     al, 4
                    call    get_option

                    cmp     al, 0                                               ; 0 -> Ir para o menu 0
                    je      menu_0
  menu_2:
                    call    clear_screen                                        ; MENU 2 -----------------------------------------------------------------------
                    lea     dx, txt_menu_2
                    call    print
                    mov     al, 2
                    call    get_option

                    cmp     al, 00                                               ; 0 -> Ir para o menu 0
                    je      menu_0
  menu_2_a:
                    call    clear_screen                                        ; MENU 2_a ---------------------------------------------------------------------
                    lea     dx, txt_menu_2_a
                    call    print
                    mov     al, 4
                    call    get_option

                    cmp     al, 00                                               ; 0 -> Ir para o menu 2
                    je      menu_2

; --------------------------------------------------------------------------------------------------------------------------------------------------------------
  exit:             int     20h                                                 ; end program
main                endp
