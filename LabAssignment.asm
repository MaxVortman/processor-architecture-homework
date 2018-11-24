; -------------------------------------------------------------------------------------	;
;	������������ ������ �1 �� ����� ���������������� �� ����� ����������				;
;	������� �3.3																		;
;	�������� ������� ������ ������.																;
;																						;
;	�������� ������ LabAssignment														;
;	�������� ������� �� ����� ����������, ������������� � ������������ � ��������		;
; -------------------------------------------------------------------------------------	;
;	�������: ����������� ������� ���������� ��������� � ��������������
;		���������� ������ � ������� RAID-6
;	������ ����� - 32 �����
;	����� ���������� ������ � ������� N+2:
;		0...N-1 - ����� ������
;		N		- ������� P
;		N+1		- ������� Q
;	���� �����, ������������ ��� ����������: GF(2^32)
;	������������ ���������: 1 0000 008D ; x^32 + x^7 + x^3 + x^2 + 1
;	����������, ������������ ��� ����������: SSE

.DATA
ModuleMask	QWORD	0000008D0000008Dh, 0000008D0000008Dh
; ����� ������� �, ��������, ������� �������� x^(a - N + 1) � �������. 
ReverseX	DWORD	0F7253097h, 0F7253097h, 0F7253097h, 0F7253097h		; x^-29
			DWORD	0EE4A61A3h, 0EE4A61A3h, 0EE4A61A3h, 0EE4A61A3h		; x^-28
			DWORD	0DC94C3CBh, 0DC94C3CBh, 0DC94C3CBh, 0DC94C3CBh		; x^-27
			DWORD	0B929871Bh, 0B929871Bh, 0B929871Bh, 0B929871Bh		; x^-26
			DWORD	072530EBBh, 072530EBBh, 072530EBBh, 072530EBBh		; x^-25
			DWORD	0E4A61D76h, 0E4A61D76h, 0E4A61D76h, 0E4A61D76h		; x^-24
			DWORD	0C94C3A61h, 0C94C3A61h, 0C94C3A61h, 0C94C3A61h		; x^-23
			DWORD	09298744Fh, 09298744Fh, 09298744Fh, 09298744Fh		; x^-22
			DWORD	02530E813h, 02530E813h, 02530E813h, 02530E813h		; x^-21
			DWORD	04A61D026h, 04A61D026h, 04A61D026h, 04A61D026h		; x^-20
			DWORD	094C3A04Ch, 094C3A04Ch, 094C3A04Ch, 094C3A04Ch		; x^-19
			DWORD	029874015h, 029874015h, 029874015h, 029874015h		; x^-18
			DWORD	0530E802Ah, 0530E802Ah, 0530E802Ah, 0530E802Ah		; x^-17
			DWORD	0A61D0054h, 0A61D0054h, 0A61D0054h, 0A61D0054h		; x^-16
			DWORD	04C3A0025h, 04C3A0025h, 04C3A0025h, 04C3A0025h		; x^-15
			DWORD	09874004Ah, 09874004Ah, 09874004Ah, 09874004Ah		; x^-14
			DWORD	030E80019h, 030E80019h, 030E80019h, 030E80019h		; x^-13
			DWORD	061D00032h, 061D00032h, 061D00032h, 061D00032h		; x^-12
			DWORD	0C3A00064h, 0C3A00064h, 0C3A00064h, 0C3A00064h		; x^-11
			DWORD	087400045h, 087400045h, 087400045h, 087400045h		; x^-10
			DWORD	0E800007h, 0E800007h, 0E800007h, 0E800007h			; x^-9
			DWORD	01D00000Eh, 01D00000Eh, 01D00000Eh, 01D00000Eh		; x^-8
			DWORD	03A00001Ch, 03A00001Ch, 03A00001Ch, 03A00001Ch		; x^-7
			DWORD	074000038h, 074000038h, 074000038h, 074000038h		; x^-6
			DWORD	0E8000070h, 0E8000070h, 0E8000070h, 0E8000070h		; x^-5
			DWORD	0D000006Dh, 0D000006Dh, 0D000006Dh, 0D000006Dh		; x^-4
			DWORD	0A0000057h, 0A0000057h, 0A0000057h, 0A0000057h		; x^-3
			DWORD	040000023h, 040000023h, 040000023h, 040000023h		; x^-2
			DWORD	080000046h, 080000046h, 080000046h, 080000046h		; x^-1
			DWORD	01h, 01h, 01h, 01h									; x^0
; � ����� 1 / (1 - x^(a - b))
ReverseXAB	DWORD	0C5A67F60h, 0C5A67F60h, 0C5A67F60h, 0C5A67F60h		; 1 / (1 - x^-29)
			DWORD	0EB53671Eh, 0EB53671Eh, 0EB53671Eh, 0EB53671Eh		; 1 / (1 - x^-28)
			DWORD	075459857h, 075459857h, 075459857h, 075459857h		; 1 / (1 - x^-27)
			DWORD	0C69FD7D6h, 0C69FD7D6h, 0C69FD7D6h, 0C69FD7D6h		; 1 / (1 - x^-26)
			DWORD	074E9D383h, 074E9D383h, 074E9D383h, 074E9D383h		; 1 / (1 - x^-25)
			DWORD	031AC5529h, 031AC5529h, 031AC5529h, 031AC5529h		; 1 / (1 - x^-24)
			DWORD	0B5864737h, 0B5864737h, 0B5864737h, 0B5864737h		; 1 / (1 - x^-23)
			DWORD	06E2C718Ch, 06E2C718Ch, 06E2C718Ch, 06E2C718Ch		; 1 / (1 - x^-22)
			DWORD	09935D482h, 09935D482h, 09935D482h, 09935D482h		; 1 / (1 - x^-21)
			DWORD	0F3C40F40h, 0F3C40F40h, 0F3C40F40h, 0F3C40F40h		; 1 / (1 - x^-20)
			DWORD	05B426B47h, 05B426B47h, 05B426B47h, 05B426B47h		; 1 / (1 - x^-19)
			DWORD	0B017EC5Bh, 0B017EC5Bh, 0B017EC5Bh, 0B017EC5Bh		; 1 / (1 - x^-18)
			DWORD	07F4FBF9Bh, 07F4FBF9Bh, 07F4FBF9Bh, 07F4FBF9Bh		; 1 / (1 - x^-17)
			DWORD	0E32BE35Fh, 0E32BE35Fh, 0E32BE35Fh, 0E32BE35Fh		; 1 / (1 - x^-16)
			DWORD	02AFA55E1h, 02AFA55E1h, 02AFA55E1h, 02AFA55E1h		; 1 / (1 - x^-15)
			DWORD	03288CA3Ah, 03288CA3Ah, 03288CA3Ah, 03288CA3Ah		; 1 / (1 - x^-14)
			DWORD	03C69E351h, 03C69E351h, 03C69E351h, 03C69E351h		; 1 / (1 - x^-13)
			DWORD	0F4FF4F8Bh, 0F4FF4F8Bh, 0F4FF4F8Bh, 0F4FF4F8Bh		; 1 / (1 - x^-12)
			DWORD	0DA1B431h, 0DA1B431h, 0DA1B431h, 0DA1B431h			; 1 / (1 - x^-11)
			DWORD	0E3F8FE4Bh, 0E3F8FE4Bh, 0E3F8FE4Bh, 0E3F8FE4Bh		; 1 / (1 - x^-10)
			DWORD	09FCFE7BBh, 09FCFE7BBh, 09FCFE7BBh, 09FCFE7BBh		; 1 / (1 - x^-9)
			DWORD	0C8C8C8A8h, 0C8C8C8A8h, 0C8C8C8A8h, 0C8C8C8A8h		; 1 / (1 - x^-8)
			DWORD	076EDDB8Fh, 076EDDB8Fh, 076EDDB8Fh, 076EDDB8Fh		; 1 / (1 - x^-7)
			DWORD	0CB2CB2AAh, 0CB2CB2AAh, 0CB2CB2AAh, 0CB2CB2AAh		; 1 / (1 - x^-6)
			DWORD	09CE73987h, 09CE73987h, 09CE73987h, 09CE73987h		; 1 / (1 - x^-5)
			DWORD	044444464h, 044444464h, 044444464h, 044444464h		; 1 / (1 - x^-4)
			DWORD	0924924DCh, 0924924DCh, 0924924DCh, 0924924DCh		; 1 / (1 - x^-3)
			DWORD	05555557Dh, 05555557Dh, 05555557Dh, 05555557Dh		; 1 / (1 - x^-2)
			DWORD	0FFFFFF85h, 0FFFFFF85h, 0FFFFFF85h, 0FFFFFF85h		; 1 / (1 - x^-1)
.CODE

MulX_32 PROC	; ��� ������ ��������� ����� ����������� �������� xmm2, xmm3 - 32 ������� ��������
				; ������ xmm4, xmm5, xmm6, r9

	pxor	xmm4, xmm4								; ��������� xmm4
	pxor	xmm5, xmm5								; xmm5
	pxor	xmm6, xmm6								; xmm6
	mov		r9, offset ModuleMask					; r9 <- ����� ������ (1 0000 008D ��� �������� ���� (4 ����))
	movdqa	xmm4, [r9]								; xmm4 <- ������

	pcmpgtd	xmm5, xmm2								; �������� ��������, � ������� ������� ���=1
	pcmpgtd	xmm6, xmm3								

	pand	xmm5, xmm4								;  � ����������� ������ ��� ��� ������ 0000008D
	pand	xmm6, xmm4								

	pslld	xmm2, 1									; ����� �������� �� ������ �����
	pslld	xmm3, 1									

	pxor	xmm2, xmm5								; ����������� ������ � ���������� ���������
	pxor	xmm3, xmm6								
	ret												

MulX_32 ENDP

; ��������� � ������� �� ������
Mul_32 PROC						; xmm0, xmm1 -- �������� ���������
								; xmm7 -- ��������� �� �������
								; ��������� �� xmm2, xmm3
								; ������ xmm2, xmm3, xmm4, xmm5, xmm6, xmm8, xmm9, r9, r10, 

	pxor	xmm2,	xmm2		; ������� �����
	pxor	xmm3,	xmm3
	mov		r10,	32			; r10 <- ������� ����� (32 ���� = 32 ��������)
l1:
	call	MulX_32				; ������� ����� �� x

	pxor	xmm8,	xmm8		; ������� xmm8
	pcmpgtd xmm8,	xmm7		; �������� ��������, � ������� ������� ���=1
	movdqa	xmm9,	xmm8		; ����������� �� xmm9

	pand	xmm8,	xmm0		; ��������� ���������� ����� �� ������ ���������
	pand	xmm9,	xmm1

	pxor	xmm2,	xmm8		; ��������� � ����� ���������
	pxor	xmm3,	xmm9

	pslld	xmm7,	1			; ����� ����� �� 1 ��� 
	
	sub		r10,	1			; �������� ������� ����� �� 1
	jg		l1					; ���������, ���� ������� ������ 0
	
	ret							; ��������� �� xmm2, xmm3

Mul_32 ENDP

; -------------------------------------------------------------------------------------	;
; void CalculateSyndromes(void *D, unsigned int N)										;
;	���������� ��������� P � Q															;
;	D - ����� �������, N - ���������� ������ ������										;
; -------------------------------------------------------------------------------------	;
CalculateSyndromes PROC	; [RCX] - D
						; RDX   - N
	mov rax, rdx		; rax <- N (������� �����)
	pxor xmm0, xmm0		; ������� xmm0
	pxor xmm1, xmm1		; ������� xmm1
	pxor xmm2, xmm2		; ������� xmm2
	pxor xmm3, xmm3		; ������� xmm3
	xor r8, r8			; ������� r8

l1: 
	call MulX_32

	; ������ ������� P 
	pxor xmm0, [rcx + r8]			; ��������� ������ 128 ��� �����
	pxor xmm1, [rcx + r8 + 16]		; ��������� 128 ���
	; ������ ������� Q
	pxor xmm2, [rcx + r8]			; ��������� ������ 128 ��� �����
	pxor xmm3, [rcx + r8 + 16]		; ��������� 128 ���

	add r8, 20h						; �������� 32 (�.�. ����� �� 32 �����) � �������� ������
	sub rax, 1						; �������� ������� ����� �� 1
	jg l1							; ���������, ���� ������� ������ 0

	; ���� ������� P �� N-�� �����
	movdqa [rcx + r8], xmm0			; ��������� ������ 128 ��� N-���� �����
	movdqa [rcx + r8 + 16], xmm1	; ������ 128
	
	add r8, 20h						; �������� � N + 1 �����
	; ���� ������� Q
	movdqa [rcx + r8], xmm2			; ��������� ������ 128 ��� N + 1 �����
	movdqa [rcx + r8 + 16], xmm3	; ������ 128

	ret
CalculateSyndromes ENDP
; -------------------------------------------------------------------------------------	;
; void Recover(void *D, unsigned int N, unsigned int a, unsigned int b)					;
;	�������������� ������ � �������� a � b (b>a)										;
;	D - ����� �������, N - ���������� ������ ������										;
; -------------------------------------------------------------------------------------	;
Recover PROC	; [RCX] - D
				; RDX   - N
				; R8	- a
				; R9	- b

	mov		rax,	20h					; ������ �� rax ����� N-��� �����
	push	rdx							; ����� � ������ ��� ��������� ����� ������ rdx �� ����, �.�. mul ��� ��������.
	mul		rdx
	pop		rdx

	movdqa	xmm10,	[rcx + rax]			; xmm10 <- ������ 128 ��� �������� P
	movdqa	xmm11,	[rcx + rax + 16]	; xmm11 <- ��������� 128 ���

	movdqa	xmm12,	[rcx + rax + 32]	; xmm12 <- ������ 128 ��� ������� Q
	movdqa	xmm13,	[rcx + rax + 48]	; xmm13 <- ��������� 128 ���

	push	r8
	push	rax
	push	r9
	call	CalculateSyndromes			; ������ �������� ��� ���������� ������
	pop		r9
	pop		rax
	pop		r8
										; ��������� � ������� ��������� �������� ��� ���������� ������
	pxor	xmm10,	[rcx + rax]			; xmm10 <- P c ������, ������ 128 ���
	pxor	xmm11,	[rcx + rax + 16]	; xmm11 <- ��������� 128 ���

	pxor	xmm12,	[rcx + rax + 32]	; xmm12 <- Q c ������, ������ 128 ���
	pxor	xmm13,	[rcx + rax + 48]	; xmm13 <- ��������� 128 ���

										; r11 <- ������ � ������� ReverseX, ������ ��� (a + 30 - N) ��� ��������� �������. 
	mov		r11,	r8					; r11 <- a
	add		r11,	1Eh					: r11 <- a + 30
	sub		r11,	rdx					; r11 <- a + 30 - N

										; rax <- �������� � ������� ReverseX, r11 * 16 (scale = 16)
	mov		rax,	10h					; rax <- 16
	push	rdx
	mul		r11							; rax <- 16 * r11
	pop		rdx

										; ������������� �������� xmm0, xmm1, xmm7 ��� ������ ��������� Mul_32
	movdqa	xmm0,	xmm12				; xmm0 <- Q c ������, ������ 128 ���
	movdqa	xmm1,	xmm13				; xmm1 <- ��������� 128 ���
	push	r9
	mov		r9,		offset ReverseX		; r9 <- ����� ������� ReverseX
	movdqa	xmm7,	[r9 + rax]			; xmm7 <- ��������� �������� �� ������� (a + 30 - N)
	call	Mul_32						; ����� Mul_32, ��������� �� xmm2, xmm3
	pop		r9

	movdqa	xmm0,	xmm10				; xmm0 <- P c ������, ������ 128 ���
	movdqa	xmm1,	xmm11				; xmm1 <- ��������� 128 ���
										; ��������� � P � ������ ��������� ������ ��������� Mul_32
	pxor	xmm0,	xmm2				; xmm0 <- P � ������ - Q � ������ * x^(a - N + 1), ������ 128 ���
	pxor	xmm1,	xmm3				; xmm1 <- ��������� 128 ���

										; r11 <- ������ � ������� ReverseXAB, ������ ��� (a + 29 - b) ��� ��������� �������. 
	mov		r11,	r8					; r11 <- a
	add		r11,	1Dh					; r11 <- a + 29
	sub		r11,	r9					; r11 <- a + 29 - b

										; rax <- �������� � ������� ReverseXAB, r11 * 16 (scale = 16)
	mov		rax,	10h					; rax <- 16
	push	rdx
	mul		r11							; rax <- 16 * r11
	pop		rdx

	push	r9
	mov		r9,		offset ReverseXAB	; r9 <- ����� ������� ReverseXAB
	movdqa	xmm7,	[r9 + rax]			; xmm7 <- ��������� �������� �� ������� (a + 29 - b)
	call	Mul_32						; ����� Mul_32, ��������� �� xmm2, xmm3
	pop		r9

										; ������� �������� ��� ����� b
	mov		rax,	20h					; rax <- 32
	push	rdx							
	mul		r9							; rax <- 32 * b
	pop		rdx

										; ������ xmm2, xmm3 (Db) �� ����� ����� b
	movdqa	[rcx + rax],		xmm2	
	movdqa	[rcx + rax + 16],	xmm3

										; ���������� Da �� xmm2, xmm3 (Da = P � ������ - Db)
	pxor	xmm2,	xmm10				; xmm2 <- p � ������ + Db, ������ 128 ���
	pxor	xmm3,	xmm11				; xmm3 <- ��������� 128 ���

										; ������� �������� ��� ����� a
	mov		rax,	20h					; rax <- 32
	push	rdx
	mul		r8							; rax <- 32 * a
	pop		rdx

										; ������ xmm2, xmm3 (Da) �� ����� ����� a 
	movdqa	[rcx + rax],		xmm2
	movdqa	[rcx + rax + 16],	xmm3

	ret
Recover ENDP
END