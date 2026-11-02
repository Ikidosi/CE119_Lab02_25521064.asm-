# ========================================================
# PH?N M? R?NG - TR?C QUAN HÓA PH? ?I?M (draw_hist)
# ========================================================
.data
# M?ng hist minh h?a k?t qu? ??u vào (4 nhóm)
hist_sample: .word 4, 2, 3, 3

# Nhãn các nhóm và ký t? v?
label_g0: .asciiz "g0:\n"
label_g1: .asciiz "g1:\n"
label_g2: .asciiz "g2:\n"
label_g3: .asciiz "g3:\n"
bar_char: .asciiz "|"
newline:  .asciiz "\n"

.text
.globl main

main:
    la   $a0, hist_sample
    li   $a1, 4
    jal  draw_hist

    li   $v0, 10
    syscall

# ========================================================
# Th? t?c draw_hist
# Tham s?: $a0 = ??a ch? m?ng hist, $a1 = s? nhóm (4)
# Yêu c?u: Là th? t?c lá, in bi?u ?? c?t ngang ?úng ??nh d?ng
# ========================================================
draw_hist:
    addi $sp, $sp, -20
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)
    sw   $s1, 8($sp)
    sw   $s2, 12($sp)
    sw   $s3, 16($sp)

    move $s0, $a0
    move $s1, $a1
    li   $s2, 0             # Ch? s? nhóm b?t ??u t? 0

dh_loop:
    beq  $s1, $zero, dh_done

    # In nhãn nhóm t??ng ?ng (g0:, g1:, g2:, g3:)
    li   $v0, 4
    beq  $s2, 0, print_g0
    beq  $s2, 1, print_g1
    beq  $s2, 2, print_g2
    beq  $s2, 3, print_g3
    j    print_continue

print_g0: la $a0, label_g0; j do_print_label
print_g1: la $a0, label_g1; j do_print_label
print_g2: la $a0, label_g2; j do_print_label
print_g3: la $a0, label_g3; j do_print_label

do_print_label:
    syscall

print_continue:
    lw   $s3, 0($s0)        # L?y s? sinh viên trong nhóm hi?n t?i
    li   $t0, 0

dh_bar_loop:
    bge  $t0, $s3, dh_bar_done
    li   $v0, 4
    la   $a0, bar_char      # In ký t? "|"
    syscall
    addi $t0, $t0, 1
    j    dh_bar_loop

dh_bar_done:
    li   $v0, 4
    la   $a0, newline
    syscall

    addi $s0, $s0, 4
    addi $s2, $s2, 1
    addi $s1, $s1, -1
    j    dh_loop

dh_done:
    lw   $ra, 0($sp)
    lw   $s0, 4($sp)
    lw   $s1, 8($sp)
    lw   $s2, 12($sp)
    lw   $s3, 16($sp)
    addi $sp, $sp, 20
    jr   $ra