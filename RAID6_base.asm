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
;	����������, ������������ ��� ����������: AVX (����� �������� �, �� � ������ ���� ������ ������� �������� ���������)

.DATA
ModuleMask	QWORD	0000008D0000008Dh
HighBitMask QWORD	8000000080000000h
ShiftMask	QWORD	0FFFFFFFEFFFFFFFFh
; ����� ������� �, ��������, ������� �������� x^(a - N + 1) � �������. 
ReverseX	QWORD	0F7253097F7253097h			; x^-29
			QWORD	0EE4A61A3EE4A61A3h			; x^-28
			QWORD	0DC94C3CBDC94C3CBh			; x^-27
			QWORD	0B929871BB929871Bh			; x^-26
			QWORD	072530EBB72530EBBh			; x^-25
			QWORD	0E4A61D76E4A61D76h			; x^-24
			QWORD	0C94C3A61C94C3A61h			; x^-23
			QWORD	09298744F9298744Fh			; x^-22
			QWORD	02530E8132530E813h			; x^-21
			QWORD	04A61D0264A61D026h			; x^-20
			QWORD	094C3A04C94C3A04Ch			; x^-19
			QWORD	02987401529874015h			; x^-18
			QWORD	0530E802A530E802Ah			; x^-17
			QWORD	0A61D0054A61D0054h			; x^-16
			QWORD	04C3A00254C3A0025h			; x^-15
			QWORD	09874004A9874004Ah			; x^-14
			QWORD	030E8001930E80019h			; x^-13
			QWORD	061D0003261D00032h			; x^-12
			QWORD	0C3A00064C3A00064h			; x^-11
			QWORD	08740004587400045h			; x^-10
			QWORD	0E8000070E800007h			; x^-9
			QWORD	01D00000E1D00000Eh			; x^-8
			QWORD	03A00001C3A00001Ch			; x^-7
			QWORD	07400003874000038h			; x^-6
			QWORD	0E8000070E8000070h			; x^-5
			QWORD	0D000006DD000006Dh			; x^-4
			QWORD	0A0000057A0000057h			; x^-3
			QWORD	04000002340000023h			; x^-2
			QWORD	08000004680000046h			; x^-1
			QWORD	00000000100000001h			; x^0
; � ����� 1 / (1 - x^(a - b))
ReverseXAB	QWORD	0C5A67F60C5A67F60h			; 1 / (1 - x^-29)
			QWORD	0EB53671EEB53671Eh			; 1 / (1 - x^-28)
			QWORD	07545985775459857h			; 1 / (1 - x^-27)
			QWORD	0C69FD7D6C69FD7D6h			; 1 / (1 - x^-26)
			QWORD	074E9D38374E9D383h			; 1 / (1 - x^-25)
			QWORD	031AC552931AC5529h			; 1 / (1 - x^-24)
			QWORD	0B5864737B5864737h			; 1 / (1 - x^-23)
			QWORD	06E2C718C6E2C718Ch			; 1 / (1 - x^-22)
			QWORD	09935D4829935D482h			; 1 / (1 - x^-21)
			QWORD	0F3C40F40F3C40F40h			; 1 / (1 - x^-20)
			QWORD	05B426B475B426B47h			; 1 / (1 - x^-19)
			QWORD	0B017EC5BB017EC5Bh			; 1 / (1 - x^-18)
			QWORD	07F4FBF9B7F4FBF9Bh			; 1 / (1 - x^-17)
			QWORD	0E32BE35FE32BE35Fh			; 1 / (1 - x^-16)
			QWORD	02AFA55E12AFA55E1h			; 1 / (1 - x^-15)
			QWORD	03288CA3A3288CA3Ah			; 1 / (1 - x^-14)
			QWORD	03C69E3513C69E351h			; 1 / (1 - x^-13)
			QWORD	0F4FF4F8BF4FF4F8Bh			; 1 / (1 - x^-12)
			QWORD	0DA1B4310DA1B431h			; 1 / (1 - x^-11)
			QWORD	0E3F8FE4BE3F8FE4Bh			; 1 / (1 - x^-10)
			QWORD	09FCFE7BB9FCFE7BBh			; 1 / (1 - x^-9)
			QWORD	0C8C8C8A8C8C8C8A8h			; 1 / (1 - x^-8)
			QWORD	076EDDB8F76EDDB8Fh			; 1 / (1 - x^-7)
			QWORD	0CB2CB2AACB2CB2AAh			; 1 / (1 - x^-6)
			QWORD	09CE739879CE73987h			; 1 / (1 - x^-5)
			QWORD	04444446444444464h			; 1 / (1 - x^-4)
			QWORD	0924924DC924924DCh			; 1 / (1 - x^-3)
			QWORD	05555557D5555557Dh			; 1 / (1 - x^-2)
			QWORD	0FFFFFF85FFFFFF85h			; 1 / (1 - x^-1)
.CODE

MulX_32 PROC	; ��� ������ ��������� ����� ����������� �������� r12, r13, r14, r15 - 32 ������� ��������
				; ������ rax, r8, r9, r10, r11

									; ��������� ���������
	xor		r8,		r8
	xor		r9,		r9
	xor		r10,	r10
	xor		r11,	r11

	mov		rax,	ModuleMask		; rax <- ������ (1 0000 008D ��� �������� ���� (2 ����))

									; ��������� ������� ��������� ������� pcmpgtd (���� ��� �������� ������ �� SSE, MMX) 
									;	�.�. �������� ������� �����, � ������� ������� ���=1
									;	��� ������������� ���������� ��� ���������
									;pcmpgtd		r8,		r12
									;pcmpgtd		r9,		r13
									;pcmpgtd		r10,	r14
									;pcmpgtd		r11,	r15
	mov		r8,		HighBitMask		; �����, ���������� ������� ���� ������� ���� 
	mov		r9,		HighBitMask		
	mov		r10,	HighBitMask		
	mov		r11,	HighBitMask		
	and		r8,		r12				; ���������� �����
	and		r9,		r13
	and		r10,	r14
	and		r11,	r15
	sar		r8,		31				; �������������� ����� ������ �� 31 ��� (����� �������� ��� ����������� �� ��� �����)
	sar		r9,		31
	sar		r10,	31
	sar		r11,	31
	ror		r8,		1				; ����������� ����� ������ (���� ��������� ��� ������� �������� ����� �� ����� ���������)
	ror		r9,		1
	ror		r10,	1
	ror		r11,	1
	sar		r8,		31				; ����� �������������� ����� ������ �� 31 ���
	sar		r9,		31
	sar		r10,	31
	sar		r11,	31
	ror		r8,		32				; ����������� ����� �� 32 ���� (����� ��� ���� ������ �� ���� �����)
	ror		r9,		32
	ror		r10,	32
	ror		r11,	32

	and		r8,		rax				; ����������� ������ ��� ��� ������ 0000008D
	and		r9,		rax
	and		r10,	rax
	and		r11,	rax
									; ��������� ������� ��������� ������� pslld 
									;	�.�. �������� ������� ����� �����
									;pslld	r12,	1
									;pslld	r13,	1
									;pslld	r14,	1
									;pslld	r15,	1
	shl		r12,	1				; ����� ����� �� 1 ���
	shl		r13,	1
	shl		r14,	1
	shl		r15,	1
	mov		rax,	ShiftMask		; rax <- �����, ���������� 32 ���, ������������ �� ������� �������� �����
	and		r12,	rax				; ���������� �����
	and		r13,	rax
	and		r14,	rax
	and		r15,	rax				
	
	xor		r12,	r8						; ����������� ������ � ���������� ���������
	xor		r13,	r9		
	xor		r14,	r10	
	xor		r15,	r11	

	ret												

MulX_32 ENDP

; ��������� � ������� �� ������
Mul_32 PROC						; r8, r9, r10, r11 -- �������� ���������
								; rax -- ��������� �� �������
								; ��������� �� r12, r13, r14, r15
								; ������ rsi, rdi, rbx, rcx, rdx

								; �������� �����
	xor		r12,	r12
	xor		r13,	r13
	xor		r14,	r14
	xor		r15,	r15
	
	mov		rsi,	32			; rsi <- ������� ����� (32 ���� = 32 ��������)
l1:
	push	r8
	push	r9
	push	r10
	push	r11
	push	rax
	call	MulX_32				; ������� ����� �� x
	pop		rax
	pop		r11
	pop		r10
	pop		r9
	pop		r8
									; ��������� ������� pcmpgtd, �.�. �������� ������� �����, � ������� ������� ���=1�
	mov		rbx,	HighBitMask		; �����, ���������� ������� ���� ������� ���� 
	and		rbx,	rax				; ���������� �����
	sar		rbx,	31				; �������������� ����� ������ �� 31 ��� (����� �������� ��� ����������� �� ��� �����)
	ror		rbx,	1				; ����������� ����� ������ (���� ��������� ��� ������� �������� ����� �� ����� ���������)
	sar		rbx,	31				; ����� �������������� ����� ������ �� 31 ���
	ror		rbx,	32				; ����������� ����� �� 32 ���� (����� ��� ���� ������ �� ���� �����)

									; �������� �� 3 ������ ��������
	mov		rcx,	rbx
	mov		rdx,	rbx
	mov		rdi,	rbx
									; ��������� ���������� �����
	and		rbx,	r8
	and		rcx,	r9
	and		rdx,	r10
	and		rdi,	r11
									; ���������� � ����� ���������
	xor		r12,	rbx
	xor		r13,	rcx
	xor		r14,	rdx
	xor		r15,	rdi

								; ��������� ������� pslld, �.�. �������� ������� ����� �����
	shl		rax,	1			; ����� ����� �� 1 ���
	and		rax,	ShiftMask	; ���������� �����

	sub		rsi,	1			; �������� ������� ����� �� 1
	jg		l1					; ���������, ���� ������� ������ 0

	ret							; ��������� �� r12, r13, r14, r15

Mul_32 ENDP

; -------------------------------------------------------------------------------------	;
; void CalculateSyndromes(void *D, unsigned int N)										;
;	���������� ��������� P � Q															;
;	D - ����� �������, N - ���������� ������ ������										;
; -------------------------------------------------------------------------------------	;
CalculateSyndromes PROC	; [RCX] - D
						; RDX   - N
						; ������ r8, r9, r10, r11, rax

	push	rsi							; ����� �������� �� ����� (�����) ����������
	push	r12
	push	r13
	push	r14
	push	r15

	mov		rsi,	rdx					; rsi <- N (������� �����)
	
										; �������� ��� ���������� �������� P
	xor		r8,		r8
	xor		r9,		r9
	xor		r10,	r10
	xor		r11,	r11
										; �������� ��� ���������� �������� Q
	xor		r12,	r12
	xor		r13,	r13
	xor		r14,	r14
	xor		r15,	r15

	xor		rax,	rax
l1: 
	push	r8							; ���������� ��������� ��� ������ ��������� ��������� �� x
	push	r9
	push	r10
	push	r11
	push	rax
	call MulX_32
	pop		rax
	pop		r11
	pop		r10
	pop		r9
	pop		r8

										; ������ ������� P
	xor		r8,		[rcx + rax]			; ��������� ������ 64 ���� �����
	xor		r9,		[rcx + rax + 8]		; ��� 64
	xor		r10,	[rcx + rax + 16]	; � ��� 64
	xor		r11,	[rcx + rax + 24]	; ��������� 64

										; ������ ������� Q
	xor		r12,	[rcx + rax]			; ��������� ������ 64 ���� �����
	xor		r13,	[rcx + rax + 8]		; ��� 64
	xor		r14,	[rcx + rax + 16]	; � ��� 64
	xor		r15,	[rcx + rax + 24]	; ��������� 64

	add		rax,	20h					; �������� 32 (�.�. ����� �� 32 �����) � �������� ������
	sub		rsi,	1					; �������� ������� ����� �� 1
	jg l1								; ���������, ���� ������� ������ 0

										; ���� ������� P �� N-�� �����	
	mov		[rcx + rax],		r8
	mov		[rcx + rax + 8],	r9
	mov		[rcx + rax + 16],	r10
	mov		[rcx + rax + 24],	r11

	add		rax,	20h						; �������� � N + 1 �����

											; ���� ������� Q
	mov		[rcx + rax],		r12
	mov		[rcx + rax + 8],	r13
	mov		[rcx + rax + 16],	r14
	mov		[rcx + rax + 24],	r15


											; ���������� �� �����
	pop		r15								
	pop		r14
	pop		r13
	pop		r12
	pop		rsi								

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

										; ������� ������������ ��� ����� ������ ���������
	push	rdi
	push	rsi
	push	rbx
	push	r12
	push	r13
	push	r14
	push	r15

	mov		rax,	20h					; ������ �� rax ����� N-��� �����
	push	rdx							; ����� � ������ ��� ��������� ����� ������ rdx �� ����, �.�. mul ��� ��������.
	mul		rdx
	pop		rdx
										; ��������� �� �������� ������� P
	mov		rdi,	[rcx + rax]		
	mov		rsi,	[rcx + rax + 8]	
	mov		r10,	[rcx + rax + 16]
	mov		r11,	[rcx + rax + 24]
	
										; ��������� �� �������� ������� Q
	mov		r12,	[rcx + rax + 32]			
	mov		r13,	[rcx + rax + 40]		
	mov		r14,	[rcx + rax + 48]	
	mov		r15,	[rcx + rax + 56]	

	push	r8
	push	r9
	push	r10
	push	r11
	push	rax
	call	CalculateSyndromes			; ������� �������� ��� ���������� ������
	pop		rax
	pop		r11
	pop		r10
	pop		r9
	pop		r8
										; ��������� � �������� ��������� �������� ��� ���������� ������
	xor		rdi,	[rcx + rax]		
	xor		rsi,	[rcx + rax + 8]	
	xor		r10,	[rcx + rax + 16]
	xor		r11,	[rcx + rax + 24]

	xor		r12,	[rcx + rax + 32]	
	xor		r13,	[rcx + rax + 40]	
	xor		r14,	[rcx + rax + 48]	
	xor		r15,	[rcx + rax + 56]	
											; ��������� �������� ��������
	xor		[rcx + rax],		rdi	
	xor		[rcx + rax + 8],	rsi	
	xor		[rcx + rax + 16],	r10	
	xor		[rcx + rax + 24],	r11	

	xor		[rcx + rax + 32],	r12		
	xor		[rcx + rax + 40],	r13		
	xor		[rcx + rax + 48],	r14		
	xor		[rcx + rax + 56],	r15		

										; rbx <- ������ � ������� ReverseX, ������ ��� (a + 30 - N) ��� ��������� �������. 
	mov		rbx,	r8					; rbx <- a
	add		rbx,	30					; rbx <- a + 30
	sub		rbx,	rdx					; rbx <- a + 30 - N

										; rax <- �������� � ������� ReverseX, rbx * 8 (scale = 8)
	mov		rax,	8					; rax <- 8
	mul		rbx							; rax <- 8 * rbx

										; ������������� �������� ��� ������ ��������� Mul_32
	push	r8
	push	r9
	push	r10
	push	r11
	push	rsi
	push	rdi
	push	rcx
	mov		rbx,	offset ReverseX		; rbx <- ����� ������� ReverseX
	mov		rax,	[rbx + rax]			; rax <- ��������� �������� �� ������� (a + 30 - N)
	mov		r8,		r12					; r8, r9, r10, r11 <- Q c ������
	mov		r9,		r13
	mov		r10,	r14
	mov		r11,	r15
	call	Mul_32						; ����� Mul_32, ��������� �� r12, r13, r14, r15
	pop		rcx
	pop		rdi
	pop		rsi
	pop		r11
	pop		r10
	pop		r9
	pop		r8
										; ��������� P � ������ � ���������� ������ ��������� Mul_32
										; P � ������ - Q � ������ * x^(a - N + 1)
	xor		r12,	rdi
	xor		r13,	rsi
	xor		r14,	r10
	xor		r15,	r11

										; r11 <- ������ � ������� ReverseXAB, ������ ��� (a + 29 - b) ��� ��������� �������. 
	mov		rbx,	r8					; r11 <- a
	add		rbx,	29					; r11 <- a + 29
	sub		rbx,	r9					; r11 <- a + 29 - b

										; rax <- �������� � ������� ReverseXAB, rbx * 8 (scale = 8)
	mov		rax,	8					; rax <- 8
	mul		rbx							; rax <- 8 * rbx

										; ������������� �������� ��� ������ ��������� Mul_32
	push	r8
	push	r9
	push	r10
	push	r11
	push	rsi
	push	rdi
	push	rcx
	mov		rbx,	offset ReverseXAB	; rbx <- ����� ������� ReverseXAB
	mov		rax,	[rbx + rax]			; rax <- ��������� �������� �� ������� (a + 29 - b)
	mov		r8,		r12					; r8, r9, r10, r11 <- P � ������ - Q � ������ * x^(a - N + 1)
	mov		r9,		r13
	mov		r10,	r14
	mov		r11,	r15
	call	Mul_32						; ����� Mul_32, ��������� �� r12, r13, r14, r15
	pop		rcx
	pop		rdi
	pop		rsi
	pop		r11
	pop		r10
	pop		r9
	pop		r8
										; ������� �������� ��� ����� b
	mov		rax,	32					; rax <- 32							
	mul		r9							; rax <- 32 * b

										; ������ Db �� ����� ����� b
	mov		[rcx + rax],		r12
	mov		[rcx + rax + 8],	r13
	mov		[rcx + rax + 16],	r14
	mov		[rcx + rax + 24],	r15

										; ���������� Da (Da = P � ������ - Db)
	xor		r12,	rdi
	xor		r13,	rsi
	xor		r14,	r10
	xor		r15,	r11
										; ������� �������� ��� ����� a
	mov		rax,	20h					; rax <- 32
	mul		r8							; rax <- 32 * a
										; ������ Da �� ����� ����� a
	mov		[rcx + rax],		r12
	mov		[rcx + rax + 8],	r13
	mov		[rcx + rax + 16],	r14
	mov		[rcx + rax + 24],	r15

										; ��������� �������� �� �����
	pop		r15								
	pop		r14
	pop		r13
	pop		r12
	pop		rbx
	pop		rsi
	pop		rdi

	ret
Recover ENDP
END