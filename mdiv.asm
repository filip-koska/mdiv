section .text

global mdiv
mdiv:
    lea r11, [rdi + 8 * rsi - 8] ; Rejestr r11 trzyma adres 
                                 ;  ostatniej cyfry dzielnej.

    lea r8, [rdx]                ; Rejestr r8 trzyma modul dzielnika.
    neg r8                       ; Latwiej jest zanegowac i potem naprawic,
                                 ; niz w druga strone.
    test rdx, rdx                ; Jezeli dzielnik jest dodatni, 
                                 ;  negacja byla niepotrzebna.
    cmovns r8, rdx

    lea r10, [rdx]               ; Rejestr r10 trzyma xor dzielnika 
                                 ;   oraz najstarszej cyfry dzielnej.
    xor r10, qword [r11]

    or rdx, -1
    lea r9, [1]                  ; Rejestr r9 trzyma znak dzielnej.
    xor qword [r11], 0           ; Sprawdzamy, czy dzielna jest ujemna.
    cmovs r9, rdx
    js .neg                      ; Jezeli dzielna jest ujemna, 
                                 ;  bierzemy z niej modul.

.division: ; Dzielenie liczb nieujemnych.
    xor edx, edx                 ; Przygotowujemy rdx do dzielenia.
    lea rcx, [rsi]

.loop:                           ; Dzielimy liczby nieujemne, 
                                 ;  znak wyniku jest ustalany pozniej.
    mov rax, [rdi + 8 * rcx - 8]
    div r8
    mov [rdi + 8 * rcx - 8], rax
    loop .loop

    or r8, -1                    ; Rejestr r8 od tej pory stanowi 
                                 ;  marker zakonczonego dzielenia.
    test r10, r10                ; Jezeli iloraz jest ujemny, 
                                 ;  negujemy iloraz w U2.
    js .neg
    xor qword [r11], 0           ; W przeciwnym przypadku 
                                 ;  sprawdzamy znak ilorazu.
    js .of                       ; Ujemny iloraz oznacza przepelnienie min/-1.
    jmp .end                     ; Jesli nie ma przepelnienia, 
                                 ;  przejdz do zakonczenia.

.neg:                            ; Negacja dzielnej/ilorazu w U2.
    lea rcx, [rsi]

.loop1:                          ; Odwracanie bitow dzielnej/ilorazu.
    not qword [rdi + 8 * rcx - 8]
    loop .loop1

    lea rcx, [rsi]
    xor eax, eax                 ; Rejestr rax trzyma lewostronny 
                                 ;  iterator po liczbie.
    stc                          ; Inicjalizujemy flage carry na 1.
    
.loop2:                          ; Inkrementacja dzielnej/ilorazu.
    adc qword [rdi + 8 * rax], 0 ; Trikowo dodajemy do kazdej cyfry 0 + carry.
                                 ; Jezeli przestanie zachodzic przeniesienie, 
                                 ;  przestaniemy dodawac.
    inc rax
    loop .loop2

    test r8, r8                  ; Jezeli r8 jest nieujemny, 
                                 ;  nie zakonczylismy dzielenia.
    jns .division                ; Jezeli nie wykonalismy dzielenia, 
                                 ;  przejdz do dzielenia.

.end:                            ; Zakonczenie: zwracanie wyniku.
    lea rax, [rdx]
    imul rax, r9                 ; Mnozymy modul reszty przez znak dzielnej.
    ret

.of:                             ; Obsluga przepelnienia.
    xor eax, eax
    div eax                      ; Zglaszamy przerwanie dzielac przez 0.