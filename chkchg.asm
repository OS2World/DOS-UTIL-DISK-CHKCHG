cseg segment
 assume cs:cseg,ds:cseg
 org 100h
start: jmp begin
aesc equ 27
cr equ 13
lf equ 10
minit db 'CHKCHG Copyright (C) 1993 Dimitri Vulis DLV@DM.COM'
mcrlf db cr,lf,'$'
mtest db cr,lf,'Testing, please wait...$'
mread db 'Reading boot sector: $'
mnochg db 'diskette has not been changed, buffers may be reused',cr,lf,'$'
myeschg db 'diskette may have been changed, buffers cannot be reused',cr,lf,'$'
mnotrdy db 'not ready (probably open)',cr,lf,'$'
munexp db 'unexpected error (probably bad diskette)',cr,lf,'$'
mctrl db 'diskette controller failed',cr,lf,'$'
magain db 'Press Enter to test again or ESC to exit...$'
mnoadrm db 'address mark not found',cr,lf,'$'
mnosec db 'sector not found',cr,lf,'$'
mok db 'success',cr,lf,'$'
mseek db 'seek failed',cr,lf,'$'
mcrc db 'data (CRC) error',cr,lf,'$'
mdrive db 'Drive '
drvlet db '?: $'
mtype1 db '5.25", 360K, 40 track',cr,lf,'$'
mtype2 db '5.25", 1.2MB, 80 track',cr,lf,'$'
mtype3 db '3.5", 720K, 80 track',cr,lf,'$'
mtype4 db '3.5", 1.44MB, 80 track',cr,lf,'$'
munktype db 'Unknown type '
mtype db '?',cr,lf,'$'
drv_no db 0
drv_max db 0
begin:
 mov dx,offset minit
 call prt
loop1:
 mov ah,08h
 mov dl,drv_no
 int 13h
 mov drv_max,dl
;print drive letter
 mov al,drv_no
 add al,'A'
 mov drvlet,al
 mov dx,offset mdrive
 call prt
 mov dx,offset mtype1
 cmp bl,1
 jz prtm
 mov dx,offset mtype2
 cmp bl,2
 jz prtm
 mov dx,offset mtype3
 cmp bl,3
 jz prtm
 mov dx,offset mtype4
 cmp bl,4
 jz prtm
 add bl,'0'
 mov mtype,bl
 mov dx,offset munktype
prtm:
 call prt
 inc drv_no
 mov al,drv_max
 cmp al,drv_no
 jg loop1
test0:
 mov dx,offset mtest
 call prt
 mov drv_no,0
 mov ah,0 ; reset
 mov dl,0
 int 13h
 mov dx,offset mcrlf
 call decode_ah
loop2:
 mov al,drv_no
 add al,'A'
 mov drvlet,al
 mov dx,offset mdrive
 call prt
 mov ah,16h
 mov dl,drv_no
 int 13h
 mov dx,offset mnochg
 call decode_ah
 mov dx,offset mread
 call prt
 mov ax,0201h ;read 1
 mov bx,offset lastb
 mov cx,1 ;boot sector
 mov dl,drv_no
 mov dh,ch
 int 13h
 mov dx,offset mok
 call decode_ah
 inc drv_no
 mov al,drv_max
 cmp al,drv_no
 jg loop2
 mov dx,offset magain
 call prt
 mov ax,0c08h ; clear buffer & read a char
 int 21h
 cmp al,aesc
 jnz test0
 ret
decode_ah:
 or ah,ah
 jz prt
 mov dx,offset mnoadrm
 cmp ah,02h
 jz prt
 mov dx,offset mnosec
 cmp ah,02h
 jz prt
 mov dx,offset mcrc
 cmp ah,02h
 jz prt
 mov dx,offset mctrl
 cmp ah,20h
 jz prt
 mov dx,offset mseek
 cmp ah,40h
 jz prt
 mov dx,offset myeschg
 cmp ah,06h
 jz prt
 mov dx,offset mnotrdy
 cmp ah,80h
 jz prt
 mov dx,offset munexp
prt:
 mov ah,9
 int 21h
 ret
lastb equ $
cseg ends
 end start
