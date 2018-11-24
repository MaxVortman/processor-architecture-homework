; -------------------------------------------------------------------------------------	;
;	Лабораторная работа №1 по курсу Программирование на языке ассемблера				;
;	Вариант №3.3																		;
;	Выполнил студент Шамрай Максим.																;
;																						;
;	Исходный модуль LabAssignment														;
;	Содержит функции на языке ассемблера, разработанные в соответствии с заданием		;
; -------------------------------------------------------------------------------------	;
;	Задание: Реализовать функции вычисления синдромов и восстановления
;		утраченных дисков в массиве RAID-6
;	Размер блока - 32 байта
;	Общее количество блоков в страйпе N+2:
;		0...N-1 - блоки данных
;		N		- синдром P
;		N+1		- миндром Q
;	Поле Галуа, используемое для вычислений: GF(2^32)
;	Неприводимый многочлен: 1 0000 008D ; x^32 + x^7 + x^3 + x^2 + 1
;	Технология, используемая при реализации: SSE

.DATA
ModuleMask	QWORD	0000008D0000008Dh, 0000008D0000008Dh
; будет удобней и, возможно, быстрее выписать x^(a - N + 1) в таблицу. 
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
; а также 1 / (1 - x^(a - b))
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

MulX_32 PROC	; для работы процедуры нужно подготовить регистры xmm2, xmm3 - 32 байтное множимое
				; портит xmm4, xmm5, xmm6, r9

	pxor	xmm4, xmm4								; обнуление xmm4
	pxor	xmm5, xmm5								; xmm5
	pxor	xmm6, xmm6								; xmm6
	mov		r9, offset ModuleMask					; r9 <- адрес модуля (1 0000 008D без старшего бита (4 раза))
	movdqa	xmm4, [r9]								; xmm4 <- модуль

	pcmpgtd	xmm5, xmm2								; Выделить элементы, у которых старший бит=1
	pcmpgtd	xmm6, xmm3								

	pand	xmm5, xmm4								;  и подготовить только для них модуль 0000008D
	pand	xmm6, xmm4								

	pslld	xmm2, 1									; Сдвиг операнда на разряд влево
	pslld	xmm3, 1									

	pxor	xmm2, xmm5								; Прибавление модуля к выделенным элементам
	pxor	xmm3, xmm6								
	ret												

MulX_32 ENDP

; умножение в столбик по модулю
Mul_32 PROC						; xmm0, xmm1 -- множимый многочлен
								; xmm7 -- константа из таблицы
								; результат на xmm2, xmm3
								; портит xmm2, xmm3, xmm4, xmm5, xmm6, xmm8, xmm9, r9, r10, 

	pxor	xmm2,	xmm2		; обнуляю сумму
	pxor	xmm3,	xmm3
	mov		r10,	32			; r10 <- счетчик цикла (32 бита = 32 итерации)
l1:
	call	MulX_32				; умножаю сумму на x

	pxor	xmm8,	xmm8		; обнуляю xmm8
	pcmpgtd xmm8,	xmm7		; выделить элементы, у которых старший бит=1
	movdqa	xmm9,	xmm8		; скопировать на xmm9

	pand	xmm8,	xmm0		; применить полученную маску на первый множитель
	pand	xmm9,	xmm1

	pxor	xmm2,	xmm8		; прибавить к сумме результат
	pxor	xmm3,	xmm9

	pslld	xmm7,	1			; сдвиг влево на 1 бит 
	
	sub		r10,	1			; уменьшаю счетчик цикла на 1
	jg		l1					; повторить, если счетчик больше 0
	
	ret							; результат на xmm2, xmm3

Mul_32 ENDP

; -------------------------------------------------------------------------------------	;
; void CalculateSyndromes(void *D, unsigned int N)										;
;	Вычисление синдромов P и Q															;
;	D - Адрес страйпа, N - количество дисков данных										;
; -------------------------------------------------------------------------------------	;
CalculateSyndromes PROC	; [RCX] - D
						; RDX   - N
	mov rax, rdx		; rax <- N (счетчик цикла)
	pxor xmm0, xmm0		; обнуляю xmm0
	pxor xmm1, xmm1		; обнуляю xmm1
	pxor xmm2, xmm2		; обнуляю xmm2
	pxor xmm3, xmm3		; обнуляю xmm3
	xor r8, r8			; обнуляю r8

l1: 
	call MulX_32

	; считаю синдром P 
	pxor xmm0, [rcx + r8]			; прибавляю первые 128 бит блока
	pxor xmm1, [rcx + r8 + 16]		; последние 128 бит
	; считаю синдром Q
	pxor xmm2, [rcx + r8]			; прибавляю первые 128 бит блока
	pxor xmm3, [rcx + r8 + 16]		; последние 128 бит

	add r8, 20h						; добавляю 32 (т.к. блоки по 32 байта) к регистру сдвига
	sub rax, 1						; уменьшаю счетчик цикла на 1
	jg l1							; повторить, если счетчик больше 0

	; пишу синдром P на N-ое место
	movdqa [rcx + r8], xmm0			; записываю первые 128 бит N-ного блока
	movdqa [rcx + r8 + 16], xmm1	; вторые 128
	
	add r8, 20h						; перехожу к N + 1 месту
	; пишу синдром Q
	movdqa [rcx + r8], xmm2			; записываю первые 128 бит N + 1 блока
	movdqa [rcx + r8 + 16], xmm3	; вторые 128

	ret
CalculateSyndromes ENDP
; -------------------------------------------------------------------------------------	;
; void Recover(void *D, unsigned int N, unsigned int a, unsigned int b)					;
;	Восстановление блоков с номерами a и b (b>a)										;
;	D - Адрес страйпа, N - количество дисков данных										;
; -------------------------------------------------------------------------------------	;
Recover PROC	; [RCX] - D
				; RDX   - N
				; R8	- a
				; R9	- b

	mov		rax,	20h					; считаю на rax сдвиг N-ого блока
	push	rdx							; здесь и дальше при умножении будем класть rdx на стек, т.к. mul его обнуляет.
	mul		rdx
	pop		rdx

	movdqa	xmm10,	[rcx + rax]			; xmm10 <- первые 128 бит синдрома P
	movdqa	xmm11,	[rcx + rax + 16]	; xmm11 <- последние 128 бит

	movdqa	xmm12,	[rcx + rax + 32]	; xmm12 <- первые 128 бит синдома Q
	movdqa	xmm13,	[rcx + rax + 48]	; xmm13 <- последние 128 бит

	push	r8
	push	rax
	push	r9
	call	CalculateSyndromes			; считаю синдромы без утраченных блоков
	pop		r9
	pop		rax
	pop		r8
										; прибавляю к исодным синдромам синдромы без утраченных блоков
	pxor	xmm10,	[rcx + rax]			; xmm10 <- P c чертой, первые 128 бит
	pxor	xmm11,	[rcx + rax + 16]	; xmm11 <- последние 128 бит

	pxor	xmm12,	[rcx + rax + 32]	; xmm12 <- Q c чертой, первые 128 бит
	pxor	xmm13,	[rcx + rax + 48]	; xmm13 <- последние 128 бит

										; r11 <- индекс в таблице ReverseX, считаю как (a + 30 - N) так построена таблица. 
	mov		r11,	r8					; r11 <- a
	add		r11,	1Eh					: r11 <- a + 30
	sub		r11,	rdx					; r11 <- a + 30 - N

										; rax <- смещение в таблице ReverseX, r11 * 16 (scale = 16)
	mov		rax,	10h					; rax <- 16
	push	rdx
	mul		r11							; rax <- 16 * r11
	pop		rdx

										; подготавливаю регистры xmm0, xmm1, xmm7 для вызова процедуры Mul_32
	movdqa	xmm0,	xmm12				; xmm0 <- Q c чертой, первые 128 бит
	movdqa	xmm1,	xmm13				; xmm1 <- последние 128 бит
	push	r9
	mov		r9,		offset ReverseX		; r9 <- адрес таблицы ReverseX
	movdqa	xmm7,	[r9 + rax]			; xmm7 <- табличное значение по индексу (a + 30 - N)
	call	Mul_32						; вызов Mul_32, результат на xmm2, xmm3
	pop		r9

	movdqa	xmm0,	xmm10				; xmm0 <- P c чертой, первые 128 бит
	movdqa	xmm1,	xmm11				; xmm1 <- последние 128 бит
										; прибавляю к P с чертой результат вызова процедуры Mul_32
	pxor	xmm0,	xmm2				; xmm0 <- P с чертой - Q с чертой * x^(a - N + 1), первые 128 бит
	pxor	xmm1,	xmm3				; xmm1 <- последние 128 бит

										; r11 <- индекс в таблице ReverseXAB, считаю как (a + 29 - b) так построена таблица. 
	mov		r11,	r8					; r11 <- a
	add		r11,	1Dh					; r11 <- a + 29
	sub		r11,	r9					; r11 <- a + 29 - b

										; rax <- смещение в таблице ReverseXAB, r11 * 16 (scale = 16)
	mov		rax,	10h					; rax <- 16
	push	rdx
	mul		r11							; rax <- 16 * r11
	pop		rdx

	push	r9
	mov		r9,		offset ReverseXAB	; r9 <- адрес таблицы ReverseXAB
	movdqa	xmm7,	[r9 + rax]			; xmm7 <- табличное значение по индексу (a + 29 - b)
	call	Mul_32						; вызов Mul_32, результат на xmm2, xmm3
	pop		r9

										; подсчет смещения для блока b
	mov		rax,	20h					; rax <- 32
	push	rdx							
	mul		r9							; rax <- 32 * b
	pop		rdx

										; запись xmm2, xmm3 (Db) на место блока b
	movdqa	[rcx + rax],		xmm2	
	movdqa	[rcx + rax + 16],	xmm3

										; вычисление Da на xmm2, xmm3 (Da = P с чертой - Db)
	pxor	xmm2,	xmm10				; xmm2 <- p с чертой + Db, первые 128 бит
	pxor	xmm3,	xmm11				; xmm3 <- последние 128 бит

										; подсчет смещения для блока a
	mov		rax,	20h					; rax <- 32
	push	rdx
	mul		r8							; rax <- 32 * a
	pop		rdx

										; запись xmm2, xmm3 (Da) на место блока a 
	movdqa	[rcx + rax],		xmm2
	movdqa	[rcx + rax + 16],	xmm3

	ret
Recover ENDP
END