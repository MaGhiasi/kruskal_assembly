; Kruskal algorithm for float
%include "asm_io.inc"

segment .data
adjacency_matrix :      dd 0.0, 2.1, 0.0, 6.1, 0.0
                        dd 2.1, 0.0, 3.1, 8.1, 5.1
                        dd 0.0, 3.1, 0.0, 0.0, 7.1
                        dd 6.1, 8.1, 0.0, 0.0, 9.1
                        dd 0.0, 5.1, 7.1, 9.1, 0.0

; adjacency_matrix:     dd 0.0  ,50.0  ,60.0  ,0.0   ,0.0   ,0.0   ,0.0  
;                       dd 50.0 ,0.0   ,0.0   ,120.0 ,90.0  ,0.0   ,0.0
;                       dd 60.0 ,0.0   ,0.0   ,0.0   ,0.0   ,50.0  ,0.0
;                       dd 0.0  ,120.0 ,0.0   ,0.0   ,0.0   ,80.0  ,70.0
;                       dd 0.0  ,90.0  ,0.0   ,0.0   ,0.0   ,0.0   ,40.0
;                       dd 0.0  ,0.0   ,50.0  ,80.0  ,0.0   ,0.0   ,140.0
;                       dd 0.0  ,0.0   ,0.0   ,70.0  ,40.0  ,140.0 ,0.0

; adjacency_matrix:     dd 0.0, 3.0, 1.0, 6.0, 0.0, 0.0
;                       dd 3.0, 0.0, 5.0, 0.0, 3.0, 0.0
;                       dd 1.0, 5.0, 0.0, 5.0, 6.0, 4.0
;                       dd 6.0, 0.0, 5.0, 0.0, 0.0, 2.0
;                       dd 0.0, 3.0, 6.0, 0.0, 0.0, 6.0
;                       dd 0.0, 0.0, 4.0, 2.0, 6.0, 0.0

matrix_length:  dd 5
picked_edges :  times 25 dd 0.0
visited: times 5 dd 0

zero: dd 0.0
have_cycle: dd 0

a_b:  dd -1, -1               ;a,b
min_value : dd 0.0
sum_value :       dd 0.0
edge_count: dd 0

sum_value_lable: dd "min_value : ",0
matrix_lable: dd "adjacency_matrix :",0
number: dd "edge ",0
arrow: dd " => (",0
space: dd " , ",0
val_comment: dd ") min_value = ",0

segment .text
        global  _asm_main
_asm_main:
        enter   0,0
        pusha

        push    dword [matrix_length]   ;call kruskal
        push    adjacency_matrix
        call    kruskal

        call    print_nl                ;print message
        mov     eax,matrix_lable        
        call    print_string
        call    print_nl

        push    dword[matrix_length]    ;print adjacency matrix
        push    picked_edges
        call    print_matrix

        call    print_nl                ;print message
        mov     eax,sum_value_lable
        call    print_string
        call    print_nl

        mov     eax,[sum_value]         ;print minimum min_value
        call    print_float
        call    print_nl

main_end:
        popa
        leave                     
        ret


kruskal:
        enter 0,0
        pusha
        mov     esi,[ebp+8]             ;esi = address of adjacency_matrix

kruskal_loop:
        mov     ecx,[ebp+12]            ;ecx=length
        dec     ecx
        cmp     [edge_count],ecx
        jge     kruskal_end             ;while edge_count < length-1 :       
        inc     ecx
        
        push    dword [ebp+12]          ;length
        push    dword [ebp+8]           ;adjacency matrix
        call    find_first        ;a,b => found by find_first 
        
        cmp     dword [a_b],0
        jl     kruskal_end              ;if a >= 0 (there is edge)


        mov     eax,dword[a_b]          
        mov     ebx,dword[a_b+4]
        imul    eax,ecx
        add     eax,ebx
        mov     eax,dword[esi+4*eax] 
        mov     dword[min_value],eax        ;min_value = adjacency_matrix[a][b]

        
        push    dword[ebp+12]           ;length
        push    dword[ebp+8]            ;adjacency matrix
        call    find_min_value

        push    ecx
        
visited_loop:
        mov     dword [visited+ecx*4 - 4], 0
        loop    visited_loop            ;visited = an array of zeros 
        
        pop     ecx
        
        mov     eax, dword [a_b]        ;picked_edges[a][b] = cost[a][b]
        mov     ebx, dword [a_b+4]
        imul    eax,ecx
        add     eax,ebx
        fld     dword [adjacency_matrix+4*eax]
        fstp    dword [picked_edges+4*eax]

        mov     ebx, dword [a_b]        ;picked_edges[b][a] = cost[b][a]
        mov     eax, dword [a_b+4]
        imul    eax,ecx
        add     eax,ebx
        fld     dword [adjacency_matrix+4*eax]
        fstp    dword [picked_edges+4*eax]
        
        mov     dword [have_cycle],0    ; call DFS to find out
                                        ; if there is cycle
        push    dword [a_b]
        push    dword [a_b]
        push    dword [ebp+12]
        call    DFS

        cmp     dword [have_cycle],0    ;if there is cycle 
        jne     kruskal_else            ;delete edge in else


kruskal_if:                             ;print accepted edge
        mov     eax,number              ;print number 
        call    print_string        
        mov     eax,[edge_count]
        call    print_int

        mov     eax,arrow
        call    print_string

        mov     eax,dword[a_b]          ;print vertices
        call    print_int
        
        mov     eax,space
        call    print_string
        
        mov     eax,dword[a_b+4]
        call    print_int
        
        mov     eax,val_comment
        call    print_string

        mov     eax,[min_value]             ;print min_value of edge
        call    print_float
        call    print_nl

        inc     dword [edge_count]      ;edge_count+1

        fld     dword [min_value]           ;sum_value += min_value of edge
        fld     dword [sum_value]
        faddp    ST1
        fstp    dword [sum_value]
        jmp     after_else

kruskal_else:                           ;delete edge from 
        mov     eax, dword [a_b]        ;pcked edges
        mov     ebx, dword [a_b+4]
        imul    eax,ecx
        add     eax,ebx
        fld     dword [zero]
        fstp    dword [picked_edges+4*eax]

        mov     ebx, dword [a_b]
        mov     eax, dword [a_b+4]
        imul    ebx,ecx
        add     eax,ebx
        fld     dword [zero]
        fstp    dword [picked_edges+4*eax]

after_else:                             ;delete edge from graph
        mov     eax, dword [a_b]        ;after checking edge 
        mov     ebx, dword [a_b+4]
        imul    eax,ecx
        add     eax,ebx
        fld     dword [zero]
        fstp    dword [adjacency_matrix+4*eax]

        mov     ebx, dword [a_b]
        mov     eax, dword [a_b+4]
        imul    eax,ecx
        add     eax,ebx
        fld     dword [zero]
        fstp    dword [adjacency_matrix+4*eax]

        jmp     kruskal_loop

kruskal_end:
        popa
        leave
        ret  8   


DFS:
        enter 4,0
        pusha
        mov     esi,[ebp+16]            ;esi = previous vertex
        mov     edx,[ebp+12]            ;edx = vertex
        mov     ecx,[ebp+8]             ;ecx = length
        mov     dword[visited+4*edx],1
        mov     [ebp-4],edx
        mov     ebx,0                   ;ebx=i

DFS_loop:  
        cmp     ebx,ecx                 ;check all vertices
        jge     DFS_end

        mov     eax,[ebp-4]
        imul    eax,ecx
        add     eax,ebx
        fld     dword [zero]
        fld     dword[picked_edges+eax*4]
        fcomip  ST1
        fcomp    ST0
        jbe     DFS_loop_rest           ;there is no edge between

        cmp     dword [visited+4*ebx],0 ;vertex haven't been visited
        jg     DFS_else

        push    dword[ebp-4]            ;call DFS for 
        push    ebx                     ;not visited edges
        push    ecx
        call    DFS
        jmp     DFS_loop_rest

DFS_else:                      ;vertex have been visitd before

        cmp     ebx,esi                 ;check with previous vertex
        je      DFS_loop_rest
        
        mov     dword[have_cycle],1    ;if have cycle ends
        jmp     DFS_end 

DFS_loop_rest:
        inc     ebx
        jmp     DFS_loop

DFS_end:        
        popa
        leave
        ret  12


find_min_value:
        enter 4,0
        pusha
        mov     esi,[ebp+8]         ;esi = adjacency matrix
        mov     edx,[ebp+12]        ;edx = length
        mov     [ebp - 4], edx
        mov     ecx,0   
loopy1:
        cmp     ecx,[ebp - 4]       ;check all edges to find min
        jge      find_min_value_end
        mov     ebx,0
loopy2:
        cmp     ebx,[ebp - 4]
        jge     loopy2_end
        mov     eax,ecx
        imul    eax,[ebp - 4] 
        add     eax,ebx

        fld     dword [zero]            ;check if there is edge
        fld     dword [esi+eax*4]
        fcomip  ST1
        fcomp    ST0
        jbe     loopy2_rest
        
        fld     dword [min_value]           ;check with minimum edge
        fld     dword [esi+eax*4]
        fcomip  ST1
        fcomp    ST0
        jae     loopy2_rest
        
        mov     eax,dword [esi+eax*4]
        mov     [min_value],eax
        mov     [a_b],ecx
        
        mov     [a_b+4],ebx
       
loopy2_rest:
        inc     ebx
        jmp     loopy2

loopy2_end:
        inc     ecx
        jmp     loopy1

find_min_value_end: 
        popa
        leave
        ret  8



find_first:
        enter 0,0
        pusha
        mov     esi,[ebp+8]             ;esi=adjacency_matrix
        mov     edi,[ebp+12]            ;edi=length
        mov     ecx,0
loopx1:                                 ;check all edges to 
        cmp     ecx,edi                 ;find out if there is edge
        jge      find_first_end
        
        mov     ebx,0
loopx2:
        cmp     ebx,edi
        jge     loopx2_end
        
        fld     dword [zero]
        mov     eax,ecx
        imul    eax,edi  
        add     eax,ebx
        fld     dword [esi+eax*4]

        fcomip  ST1
        fstp    ST0
        ja      is_true                 ;find first edge and finish

        inc     ebx
        jmp     loopx2

loopx2_end:
        inc     ecx
        jmp     loopx1
        jmp     find_first_end
is_true:
        mov     dword [a_b],ecx
        mov     dword [a_b+4],ebx

find_first_end:        
        popa
        leave
        ret  8



print_matrix:
        enter 0,0
        pusha
        mov     ebx,[ebp+8]             ;address of array
        mov     ecx,[ebp+12]            ;ecx=length
        mov     esi,0
loop1:
        mov     edi,0
loop2:  
        mov     eax,[ebx]
        call    print_float
        mov     al,' '
        call    print_char
        mov     al,'|'
        call    print_char
        mov     al,' '
        call    print_char

        add     ebx,4
        inc     edi
        cmp     edi,ecx
        jl      loop2

        mov     al,10
        call    print_char
        inc     esi
        cmp     esi,ecx
        jl     loop1

        popa
        leave
        ret     8