# ========================================================
# TN3 - NG?N X?P: KI?M TRA NGO?C CÂN B?NG
# ========================================================
.data
# Chu?i cá nhân P (v?i k=7 c?p ngo?c l?ng nhau)
str_P: .asciiz "([{([{()}])}])"

.text
.globl main

main:
    la   $a0, str_P
    jal  check_brackets
    
    # $v0 ch?a v? trí l?i, $v1 ch?a mã l?i
    move $s0, $v0
    move $s1, $v1

    # In mã l?i ($v1)
    li   $v0, 1
    move $a0, $s1
    syscall

    li   $v0, 10
    syscall

# ========================================================
# Th? t?c check_brackets
# Tham s?: $a0 = ??a ch? chu?i .asciiz
# Tr? v?: $v0 = v? trí (??m t? 1), $v1 = mã l?i (0, 1, 2, 3)
# ========================================================
check_brackets:
    move $t9, $sp          # L?u m?c $sp ban ??u vào $t9 ?? ph?c h?i trên m?i ???ng thoát l?i
    li   $t0, 0            # $t0 = v? trí ký t? hi?n t?i (index t? 0)

cb_loop:
    add  $t1, $a0, $t0     # ??a ch? ký t? hi?n t?i trong chu?i
    lbu  $t2, 0($t1)       # ??c ký t? hi?n t?i vào $t2
    beq  $t2, $zero, cb_check_remaining  # N?u g?p ký t? k?t thúc chu?i '\0'

    # Ki?m tra các lo?i ngo?c m?: '(', '[', '{'
    li   $t3, 40           # ASCII '('
    beq  $t2, $t3, cb_push
    li   $t3, 91           # ASCII '['
    beq  $t2, $t3, cb_push
    li   $t3, 123          # ASCII '{'
    beq  $t2, $t3, cb_push

    # Ki?m tra các lo?i ngo?c ?óng: ')', ']', '}'
    li   $t3, 41           # ASCII ')'
    beq  $t2, $t3, cb_pop_close_paren
    li   $t3, 93           # ASCII ']'
    beq  $t2, $t3, cb_pop_close_bracket
    li   $t3, 125          # ASCII '}'
    beq  $t2, $t3, cb_pop_close_brace

    # Ký t? khác ngo?c thì b? qua
    j    cb_next_char

cb_push:
    # ??y ngo?c m? lên ng?n x?p
    addi $sp, $sp, -4
    sw   $t2, 0($sp)
    j    cb_next_char

cb_pop_close_paren:
    li   $t4, 40           # Ngo?c m? t??ng ?ng là '('
    j    cb_do_pop

cb_pop_close_bracket:
    li   $t4, 91           # Ngo?c m? t??ng ?ng là '['
    j    cb_do_pop

cb_pop_close_brace:
    li   $t4, 123          # Ngo?c m? t??ng ?ng là '{'
    j    cb_do_pop

cb_do_pop:
    # Ki?m tra ng?n x?p r?ng tr??c khi pop
    beq  $sp, $t9, cb_err_empty  # N?u $sp == $t9 ngh?a là ng?n x?p r?ng -> L?i mã 2
    lw   $t5, 0($sp)
    addi $sp, $sp, 4

    # So sánh ngo?c m? l?y ra t? stack ($t5) v?i ngo?c m? k? v?ng ($t4)
    bne  $t5, $t4, cb_err_mismatch # Không kh?p lo?i -> L?i mã 1
    j    cb_next_char

cb_next_char:
    addi $t0, $t0, 1
    j    cb_loop

cb_check_remaining:
    # H?t chu?i nh?ng ng?n x?p v?n còn ph?n t? -> L?i mã 3
    bne  $sp, $t9, cb_err_unclosed
    
    # Tr??ng h?p h?p l? hoàn toàn (Mã 0)
    li   $v0, 0
    li   $v1, 0
    jr   $ra

cb_err_mismatch:
    move $sp, $t9          # Ph?c h?i $sp an toàn
    addi $v0, $t0, 1       # V? trí ??m t? 1
    li   $v1, 1            # Mã l?i 1
    jr   $ra

cb_err_empty:
    move $sp, $t9          # Ph?c h?i $sp an toàn
    addi $v0, $t0, 1       # V? trí ??m t? 1
    li   $v1, 2            # Mã l?i 2
    jr   $ra

cb_err_unclosed:
    move $sp, $t9          # Ph?c h?i $sp an toàn
    addi $v0, $t0, 1       # V? trí ??m t? 1 (?? dài chu?i + 1)
    li   $v1, 3            # Mã l?i 3
    jr   $ra