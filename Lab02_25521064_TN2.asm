# ========================================================
# TN2 - TH? T?C VÀ M?NG: TH?NG KÊ ?I?M
# ========================================================
.data
# M?ng ?i?m cá nhân S[0..11] (tính theo công th?c S[i] = (A0[i] + 4) mod 11 v?i d=4)
grades: .word 10, 7, 1, 2, 6, 9, 0, 6, 10, 2, 8, 7
n_grades: .word 12

# B?ng tra grade_tab (11 ph?n t? ki?u byte quy ??i ?i?m t? 0 ??n 10 sang nhóm 0, 1, 2, 3)
# Nhóm 0: 0-3, Nhóm 1: 4-6, Nhóm 2: 7-8, Nhóm 3: 9-10
grade_tab: .byte 0, 0, 0, 0, 1, 1, 1, 2, 2, 3, 3

# M?ng hist l?u s? l??ng sinh viên t?ng nhóm (4 word kh?i t?o b?ng 0)
hist: .word 0, 0, 0, 0

# Các chu?i ??nh d?ng in k?t qu?
str_min: .asciiz "min="
str_max: .asciiz " max="
str_space: .asciiz " "
str_g0: .asciiz "g0="
str_g1: .asciiz " g1="
str_g2: .asciiz " g2="
str_g3: .asciiz " g3="
newline: .asciiz "\n"

.text
.globl main

main:
    # 1. G?i th? t?c stats ?? tìm min, max c?a m?ng ?i?m
    la   $a0, grades
    lw   $a1, n_grades
    jal  stats
    
    # L?u l?i min ($v0) và max ($v1) vào $s0 và $s1
    move $s0, $v0
    move $s1, $v1

    # In k?t qu? min, max theo ?úng ??nh d?ng: min=<giá tr?> max=<giá tr?>
    li   $v0, 4
    la   $a0, str_min
    syscall

    li   $v0, 1
    move $a0, $s0
    syscall

    li   $v0, 4
    la   $a0, str_max
    syscall

    li   $v0, 1
    move $a0, $s1
    syscall

    li   $v0, 4
    la   $a0, newline
    syscall

    # 2. G?i th? t?c histogram ?? phân nhóm ?i?m
    la   $a0, grades
    lw   $a1, n_grades
    la   $a2, grade_tab
    la   $a3, hist
    jal  histogram

    # 3. In k?t qu? histogram theo ??nh d?ng: g0=<s?> g1=<s?> g2=<s?> g3=<s?>
    la   $t8, hist
    lw   $t9, 0($t8)   # g0
    lw   $t1, 4($t8)   # g1
    lw   $t2, 8($t8)   # g2
    lw   $t3, 12($t8)  # g3

    li   $v0, 4; la $a0, str_g0; syscall
    li   $v0, 1; move $a0, $t9; syscall

    li   $v0, 4; la $a0, str_g1; syscall
    li   $v0, 1; move $a0, $t1; syscall

    li   $v0, 4; la $a0, str_g2; syscall
    li   $v0, 1; move $a0, $t2; syscall

    li   $v0, 4; la $a0, str_g3; syscall
    li   $v0, 1; move $a0, $t3; syscall

    li   $v0, 4; la $a0, newline
    syscall

    # Thoát ch??ng trình
    li   $v0, 10
    syscall

# ========================================================
# Th? t?c stats
# Tham s?: $a0 = ??a ch? m?ng word, $a1 = n (n >= 1)
# Tr? v?: $v0 = min, $v1 = max (Là th? t?c lá)
# ========================================================
stats:
    lw   $v0, 0($a0)        # min kh?i t?o b?ng ph?n t? ??u tiên
    lw   $v1, 0($a0)        # max kh?i t?o b?ng ph?n t? ??u tiên
    addi $a0, $a0, 4
    addi $a1, $a1, -1

stats_loop:
    beq  $a1, $zero, stats_done
    lw   $t0, 0($a0)
    
    # So sánh v?i min ($v0)
    slt  $t1, $t0, $v0
    beq  $t1, $zero, stats_check_max
    move $v0, $t0

stats_check_max:
    # So sánh v?i max ($v1)
    slt  $t1, $v1, $t0
    beq  $t1, $zero, stats_next
    move $v1, $t0

stats_next:
    addi $a0, $a0, 4
    addi $a1, $a1, -1
    j    stats_loop

stats_done:
    jr   $ra

# ========================================================
# Th? t?c histogram
# Tham s?: $a0 = ??a ch? m?ng ?i?m, $a1 = n, $a2 = ??a ch? grade_tab, $a3 = ??a ch? hist
# Tr? v?: Không. (Là th? t?c lá)
# ========================================================
histogram:
histogram_loop:
    beq  $a1, $zero, histogram_done
    lw   $t0, 0($a0)             # ??c ?i?m s vào $t0

    # Tra c?u nhóm: ??a ch? grade_tab + ?i?m s
    addu $t1, $a2, $t0
    lbu  $t1, 0($t1)              # $t1 = grade_tab[s] (mã nhóm)

    # Chuy?n ch? s? nhóm thành offset byte cho m?ng hist (m?i word 4 byte)
    sll  $t1, $t1, 2
    addu $t2, $a3, $t1

    # T?ng giá tr? ??m trong hist lên 1
    lw   $t3, 0($t2)
    addi $t3, $t3, 1
    sw   $t3, 0($t2)

    addi $a0, $a0, 4
    addi $a1, $a1, -1
    j    histogram_loop

histogram_done:
    jr   $ra