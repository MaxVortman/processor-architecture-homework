; -------------------------------------------------------------------------------------	;
;	������������ ������ �2 �� ����� ���������������� �� ����� ����������				;
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
;	����������, ������������ ��� ����������: AVX
.DATA
ModuleMask	DWORD	0000008Dh
; ����� ������� �, ��������, ������� �������� x^(a - N + 1) � �������. 
ReverseX	DWORD	0F7253097h			; x^-29
			DWORD	0EE4A61A3h			; x^-28
			DWORD	0DC94C3CBh			; x^-27
			DWORD	0B929871Bh			; x^-26
			DWORD	072530EBBh			; x^-25
			DWORD	0E4A61D76h			; x^-24
			DWORD	0C94C3A61h			; x^-23
			DWORD	09298744Fh			; x^-22
			DWORD	02530E813h			; x^-21
			DWORD	04A61D026h			; x^-20
			DWORD	094C3A04Ch			; x^-19
			DWORD	029874015h			; x^-18
			DWORD	0530E802Ah			; x^-17
			DWORD	0A61D0054h			; x^-16
			DWORD	04C3A0025h			; x^-15
			DWORD	09874004Ah			; x^-14
			DWORD	030E80019h			; x^-13
			DWORD	061D00032h			; x^-12
			DWORD	0C3A00064h			; x^-11
			DWORD	087400045h			; x^-10
			DWORD	0E800007h			; x^-9
			DWORD	01D00000Eh			; x^-8
			DWORD	03A00001Ch			; x^-7
			DWORD	074000038h			; x^-6
			DWORD	0E8000070h			; x^-5
			DWORD	0D000006Dh			; x^-4
			DWORD	0A0000057h			; x^-3
			DWORD	040000023h			; x^-2
			DWORD	080000046h			; x^-1
			DWORD	000000001h			; x^0
; � ����� 1 / (1 - x^(a - b))
ReverseXAB	DWORD	0C5A67F60h			; 1 / (1 - x^-29)
			DWORD	0EB53671Eh			; 1 / (1 - x^-28)
			DWORD	075459857h			; 1 / (1 - x^-27)
			DWORD	0C69FD7D6h			; 1 / (1 - x^-26)
			DWORD	074E9D383h			; 1 / (1 - x^-25)
			DWORD	031AC5529h			; 1 / (1 - x^-24)
			DWORD	0B5864737h			; 1 / (1 - x^-23)
			DWORD	06E2C718Ch			; 1 / (1 - x^-22)
			DWORD	09935D482h			; 1 / (1 - x^-21)
			DWORD	0F3C40F40h			; 1 / (1 - x^-20)
			DWORD	05B426B47h			; 1 / (1 - x^-19)
			DWORD	0B017EC5Bh			; 1 / (1 - x^-18)
			DWORD	07F4FBF9Bh			; 1 / (1 - x^-17)
			DWORD	0E32BE35Fh			; 1 / (1 - x^-16)
			DWORD	02AFA55E1h			; 1 / (1 - x^-15)
			DWORD	03288CA3Ah			; 1 / (1 - x^-14)
			DWORD	03C69E351h			; 1 / (1 - x^-13)
			DWORD	0F4FF4F8Bh			; 1 / (1 - x^-12)
			DWORD	0DA1B431h			; 1 / (1 - x^-11)
			DWORD	0E3F8FE4Bh			; 1 / (1 - x^-10)
			DWORD	09FCFE7BBh			; 1 / (1 - x^-9)
			DWORD	0C8C8C8A8h			; 1 / (1 - x^-8)
			DWORD	076EDDB8Fh			; 1 / (1 - x^-7)
			DWORD	0CB2CB2AAh			; 1 / (1 - x^-6)
			DWORD	09CE73987h			; 1 / (1 - x^-5)
			DWORD	044444464h			; 1 / (1 - x^-4)
			DWORD	0924924DCh			; 1 / (1 - x^-3)
			DWORD	05555557Dh			; 1 / (1 - x^-2)
			DWORD	0FFFFFF85h			; 1 / (1 - x^-1)
.CODE

MulX_32 PROC	; ��� ������ ��������� ����� ����������� ������� ymm1 - 32 ������� ��������
				; ������ ymm2, ymm3

	vpxor	ymm2,	ymm2,	ymm2
	vpxor	ymm3,	ymm3,	ymm3
; ymm3 <- ������ (1 0000 008D ��� �������� ���� (8 ���))
	vbroadcastss	ymm3,	ModuleMask		
; �������� ������� �����, � ������� ������� ���=1
	vpcmpgtd	ymm2,	ymm2,	ymm1
; ����������� ������ ��� ��� ������ 0000008D
	vpand		ymm2,	ymm3,	ymm2	
; �������� ������� ����� ����� �� 1
	vpslld		ymm1,	ymm1,	1		
; ����������� ������ � ���������� ���������
	vpxor		ymm1,	ymm2,	ymm1		

	ret												

MulX_32 ENDP

; ��������� � ������� �� ������
Mul_32 PROC						; ymm4 -- �������� ���������
								; rax -- �������� ��������� �� �������
								; ��������� �� ymm1
								; ������ rsi, rdi, rbx, rcx, rdx

	vpxor		ymm1,	ymm1,	ymm1							; �������� �����
	vbroadcastss ymm5,	dword ptr [r10 + rax]					; ymm5 <- ��������� �������� �� ������� (a + 30 - N)
	mov		rax,	32											; rax <- ������� ����� (32 ���� = 32 ��������)
l1:
	call	MulX_32												; ������� ����� �� x
	vpxor		ymm6,	ymm6,	ymm6
	vpcmpgtd	ymm6,	ymm6,	ymm5							; �������� ������� �����, � ������� ������� ���=1
	vpand		ymm6,	ymm4,	ymm6							; ��������� ���������� �����
	vpxor		ymm1,	ymm6,	ymm1							; ���������� � ����� ���������
	vpslld		ymm5,	ymm5,	1								; �������� ������� ����� ����� �� 1
	sub		rax,	1											; �������� ������� ����� �� 1
	jg		l1													; ���������, ���� ������� ������ 0
	ret

Mul_32 ENDP

CalculateSyndromesInternal PROC

	vpxor	ymm0,	ymm0,	ymm0
	vpxor	ymm1,	ymm1,	ymm1
	xor		rax,	rax
l1: 
	call MulX_32
; ������ ������� P
	vpxor	ymm0,	ymm0,	[rcx + rax]
; ������ ������� Q
	vpxor	ymm1,	ymm1,	[rcx + rax]			

	add		rax,	32					; �������� 32 (�.�. ����� �� 32 �����) � �������� ������
	sub		rdx,	1					; �������� ������� ����� �� 1
	jg l1								; ���������, ���� ������� ������ 0	

	ret
CalculateSyndromesInternal ENDP

; -------------------------------------------------------------------------------------	;
; void CalculateSyndromes(void *D, unsigned int N)										;
;	���������� ��������� P � Q															;
;	D - ����� �������, N - ���������� ������ ������										;
; -------------------------------------------------------------------------------------	;
CalculateSyndromes PROC	; [RCX] - D
						; RDX   - N
						; ������ rdx, rax

; �������� ��������� AVX, FMA, XGETBV �����������
; ��� ��� ����������� ����� �������������� ��� ����� ������������������.
;	push rcx
;	push rdx
;	mov eax, 1
;	cpuid
;	and ecx, 018001000h		; ��������� ����� 12-FMA, 27-OSXSAVE, 28-AVX
;	cmp ecx, 018001000h		; ��� �� ���� ����������� � 1?
;	pop rdx
;	pop rcx
;	jne FMA_NOT_SUPPORTED	; ���� ���, �� ����������� ��������� ���

	call CalculateSyndromesInternal ; ��������� �� ymm0, ymm1
	
; ���� ������� P �� N-�� �����	
	vmovdqu		ymmword ptr [rcx + rax],	ymm0

	add		rax,	32					; �������� � N + 1 �����

; ���� ������� Q
	vmovdqu		ymmword ptr [rcx + rax],	ymm1

; ������� ��� AVX ��������
	vzeroall

FMA_NOT_SUPPORTED:

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

; �������� ��������� AVX, FMA, XGETBV �����������
; ��� ��� ����������� ����� �������������� ��� ����� ������������������.
;	push rcx
;	push rdx
;	mov eax, 1
;	cpuid
;	and ecx, 018001000h		; ��������� ����� 12-FMA, 27-OSXSAVE, 28-AVX
;	cmp ecx, 018001000h		; ��� �� ���� ����������� � 1?
;	pop rdx
;	pop rcx
;	jne FMA_NOT_SUPPORTED	; ���� ���, �� ����������� ��������� ���

; ������ �� rax ����� N-��� �����
	mov		rax,	rdx		
	shl		rax,	5
; ��������� �� ������� ������� P
	vmovdqu	ymm4,	ymmword ptr [rcx + rax]
	
; ��������� �� ������� ������� Q
	vmovdqu	ymm5,	ymmword ptr [rcx + rax + 32]			

	push	rax
	push	rdx
	call CalculateSyndromesInternal			; ������� �������� ��� ���������� ������ �� ymm0, ymm1
	pop		rdx
	pop		rax

; ��������� �������� �������� � ��������� ��� ���������� ������
	vpxor	ymm0,	ymm0,	ymm4	
	vpxor	ymm1,	ymm1,	ymm5

; ������������� �������� ��� ������ ��������� Mul_32
; rax <- �������� � ������� ReverseX �� ������� (a + 30 - N) (��� ��������� �������) 
	mov		rax,	r8					; rax <- a
	add		rax,	30					; rax <- a + 30
	sub		rax,	rdx					; rax <- a + 30 - N
	shl		rax,	2
; ----------------------
	vmovdqu	ymm4,	ymm1
	lea		r10,	offset ReverseX
	call	Mul_32						; ����� Mul_32, ��������� �� ymm1, �������� �� ymm4
; ----------------------
; ��������� P � ������ � ���������� ������ ��������� Mul_32
; P � ������ - Q � ������ * x^(a - N + 1)
	vpxor	ymm1,	ymm0,	ymm1

; ������������� �������� ��� ������ ��������� Mul_32
; rax <- �������� � ������� ReverseXAB �� ������� (a + 29 - b) (��� ��������� �������)
	mov		rax,	r8					; rax <- a
	add		rax,	29					; rax <- a + 29
	sub		rax,	r9					; rax <- a + 29 - b
	shl		rax,	2
; -----------------------			
	vmovdqu	ymm4,	ymm1
	lea		r10,	offset ReverseXAB
	call	Mul_32						; ����� Mul_32, ��������� �� ymm1, �������� �� ymm4
; -----------------------
; ������� �������� ��� ����� b
	mov		rax,	r9					; rax <- b						
	shl		rax,	5					; rax <- 32 * b
; ������ Db �� ����� ����� b
	vmovdqu		ymmword ptr [rcx + rax],	ymm1
; ���������� Da (Da = P � ������ - Db)
	vpxor	ymm1,	ymm0,	ymm1
; ������� �������� ��� ����� a
	mov		rax,	r8					; rax <- a
	shl		rax,	5					; rax <- 32 * a
; ������ Da �� ����� ����� a
	vmovdqu		ymmword ptr [rcx + rax],	ymm1
; ������� ��� AVX ��������
	vzeroall

FMA_NOT_SUPPORTED:
	ret
Recover ENDP
END