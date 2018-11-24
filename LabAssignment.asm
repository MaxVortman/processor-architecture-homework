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
ModuleMask	QWORD	0000008D0000008Dh
HighBitMask QWORD	8000000080000000h
ShiftMask	QWORD	0FFFFFFFEFFFFFFFFh
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

MulX_32 PROC	; для работы процедуры нужно подготовить регистры r12, r13, r14, r15 - 32 байтное множимое
				; портит rax, r8, r9, r10, r11

									; обнуление регистров
	xor		r8,		r8
	xor		r9,		r9
	xor		r10,	r10
	xor		r11,	r11

	mov		rax,	ModuleMask		; rax <- модуль (1 0000 008D без старшего бита (2 раза))

									; следующие команды эмулируют команду pcmpgtd (ведь она доступна только на SSE, MMX) 
									;	т.е. выделяют двойные слова, у которых старший бит=1
									;	они сгруппированы специально для конвейера
									;pcmpgtd		r8,		r12
									;pcmpgtd		r9,		r13
									;pcmpgtd		r10,	r14
									;pcmpgtd		r11,	r15
	mov		r8,		HighBitMask		; маска, выделяющая старшие биты двойных слов 
	mov		r9,		HighBitMask		
	mov		r10,	HighBitMask		
	mov		r11,	HighBitMask		
	and		r8,		r12				; применение маски
	and		r9,		r13
	and		r10,	r14
	and		r11,	r15
	sar		r8,		31				; арифметический сдвиг вправо на 31 бит (чтобы знаковый бит размножился на все слово)
	sar		r9,		31
	sar		r10,	31
	sar		r11,	31
	ror		r8,		1				; циклический сдвиг вправо (чтоб перенести бит первого двойного слова на место знакового)
	ror		r9,		1
	ror		r10,	1
	ror		r11,	1
	sar		r8,		31				; снова арифметический сдвиг вправо на 31 бит
	sar		r9,		31
	sar		r10,	31
	sar		r11,	31
	ror		r8,		32				; циклический сдвиг на 32 бита (чтобы все биты встали на свое место)
	ror		r9,		32
	ror		r10,	32
	ror		r11,	32

	and		r8,		rax				; подготовить только для них модуль 0000008D
	and		r9,		rax
	and		r10,	rax
	and		r11,	rax
									; следующие команды эмулируют команду pslld 
									;	т.е. сдвигают двойные слова влево
									;pslld	r12,	1
									;pslld	r13,	1
									;pslld	r14,	1
									;pslld	r15,	1
	shl		r12,	1				; сдвиг влево на 1 бит
	shl		r13,	1
	shl		r14,	1
	shl		r15,	1
	mov		rax,	ShiftMask		; rax <- маска, обнуляющая 32 бит, сдвинувшийся от второго двойного слова
	and		r12,	rax				; применение маски
	and		r13,	rax
	and		r14,	rax
	and		r15,	rax				
	
	xor		r12,	r8						; Прибавление модуля к выделенным элементам
	xor		r13,	r9		
	xor		r14,	r10	
	xor		r15,	r11	

	ret												

MulX_32 ENDP

; умножение в столбик по модулю
Mul_32 PROC						; r8, r9, r10, r11 -- множимый многочлен
								; rax -- константа из таблицы
								; результат на r12, r13, r14, r15
								; портит rsi, rdi, rbx, rcx, rdx

								; обнуляем сумму
	xor		r12,	r12
	xor		r13,	r13
	xor		r14,	r14
	xor		r15,	r15
	
	mov		rsi,	32			; rsi <- счетчик цикла (32 бита = 32 итерации)
l1:
	push	r8
	push	r9
	push	r10
	push	r11
	push	rax
	call	MulX_32				; умножаю сумму на x
	pop		rax
	pop		r11
	pop		r10
	pop		r9
	pop		r8
									; эмулируем команду pcmpgtd, т.е. выделяем двойные слова, у которых старший бит=1ы
	mov		rbx,	HighBitMask		; маска, выделяющая старшие биты двойных слов 
	and		rbx,	rax				; применение маски
	sar		rbx,	31				; арифметический сдвиг вправо на 31 бит (чтобы знаковый бит размножился на все слово)
	ror		rbx,	1				; циклический сдвиг вправо (чтоб перенести бит первого двойного слова на место знакового)
	sar		rbx,	31				; снова арифметический сдвиг вправо на 31 бит
	ror		rbx,	32				; циклический сдвиг на 32 бита (чтобы все биты встали на свое место)

									; копируем на 3 других регистра
	mov		rcx,	rbx
	mov		rdx,	rbx
	mov		rdi,	rbx
									; применяем полученную маску
	and		rbx,	r8
	and		rcx,	r9
	and		rdx,	r10
	and		rdi,	r11
									; прибавляем к сумме результат
	xor		r12,	rbx
	xor		r13,	rcx
	xor		r14,	rdx
	xor		r15,	rdi

								; эмулируем команду pslld, т.е. сдвигаем двойные слова влево
	shl		rax,	1			; сдвиг влево на 1 бит
	and		rax,	ShiftMask	; применение маски

	sub		rsi,	1			; уменьшаю счетчик цикла на 1
	jg		l1					; повторить, если счетчик больше 0

	ret							; результат на r12, r13, r14, r15

Mul_32 ENDP

; -------------------------------------------------------------------------------------	;
; void CalculateSyndromes(void *D, unsigned int N)										;
;	Вычисление синдромов P и Q															;
;	D - Адрес страйпа, N - количество дисков данных										;
; -------------------------------------------------------------------------------------	;
CalculateSyndromes PROC	; [RCX] - D
						; RDX   - N
						; портит r8, r9, r10, r11, rax

	push	rsi							; хотим работать со всеми (почти) регистрами
	push	r12
	push	r13
	push	r14
	push	r15

	mov		rsi,	rdx					; rsi <- N (счетчик цикла)
	
										; регистры для вычисления синдрома P
	xor		r8,		r8
	xor		r9,		r9
	xor		r10,	r10
	xor		r11,	r11
										; регистры для вычисления синдрома Q
	xor		r12,	r12
	xor		r13,	r13
	xor		r14,	r14
	xor		r15,	r15

	xor		rax,	rax
l1: 
	push	r8							; подготовка регистров для вызова процедуры умножения на x
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

										; считаю синдром P
	xor		r8,		[rcx + rax]			; прибавляю первые 64 бита блока
	xor		r9,		[rcx + rax + 8]		; еще 64
	xor		r10,	[rcx + rax + 16]	; и еще 64
	xor		r11,	[rcx + rax + 24]	; последние 64

										; считаю синдром Q
	xor		r12,	[rcx + rax]			; прибавляю первые 64 бита блока
	xor		r13,	[rcx + rax + 8]		; еще 64
	xor		r14,	[rcx + rax + 16]	; и еще 64
	xor		r15,	[rcx + rax + 24]	; последние 64

	add		rax,	20h					; добавляю 32 (т.к. блоки по 32 байта) к регистру сдвига
	sub		rsi,	1					; уменьшаю счетчик цикла на 1
	jg l1								; повторить, если счетчик больше 0

										; пишу синдром P на N-ое место	
	mov		[rcx + rax],		r8
	mov		[rcx + rax + 8],	r9
	mov		[rcx + rax + 16],	r10
	mov		[rcx + rax + 24],	r11

	add		rax,	20h						; перехожу к N + 1 месту

											; пишу синдром Q
	mov		[rcx + rax],		r12
	mov		[rcx + rax + 8],	r13
	mov		[rcx + rax + 16],	r14
	mov		[rcx + rax + 24],	r15


											; возвращаем на место
	pop		r15								
	pop		r14
	pop		r13
	pop		r12
	pop		rsi								

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
	push	rdi
	push	rsi
	push	rbx
	push	r12
	push	r13
	push	r14
	push	r15

	mov		rax,	20h					; считаю на rax сдвиг N-ого блока
	push	rdx							; здесь и дальше при умножении будем класть rdx на стек, т.к. mul его обнуляет.
	mul		rdx
	pop		rdx
										; записываю на регистры синдром P
	mov		rdi,	[rcx + rax]		
	mov		rsi,	[rcx + rax + 8]	
	mov		r10,	[rcx + rax + 16]
	mov		r11,	[rcx + rax + 24]
	
										; записываю на регистры синдром Q
	mov		r12,	[rcx + rax + 32]			
	mov		r13,	[rcx + rax + 40]		
	mov		r14,	[rcx + rax + 48]	
	mov		r15,	[rcx + rax + 56]	

	push	r8
	push	r9
	push	r10
	push	r11
	push	rax
	call	CalculateSyndromes			; считает синдромы без утраченных блоков
	pop		rax
	pop		r11
	pop		r10
	pop		r9
	pop		r8
										; прибавляю к исходным синдромам синдромы без утраченных блоков
	xor		rdi,	[rcx + rax]		
	xor		rsi,	[rcx + rax + 8]	
	xor		r10,	[rcx + rax + 16]
	xor		r11,	[rcx + rax + 24]

	xor		r12,	[rcx + rax + 32]	
	xor		r13,	[rcx + rax + 40]	
	xor		r14,	[rcx + rax + 48]	
	xor		r15,	[rcx + rax + 56]	
											; возвращаю исходные синдромы
	xor		[rcx + rax],		rdi	
	xor		[rcx + rax + 8],	rsi	
	xor		[rcx + rax + 16],	r10	
	xor		[rcx + rax + 24],	r11	

	xor		[rcx + rax + 32],	r12		
	xor		[rcx + rax + 40],	r13		
	xor		[rcx + rax + 48],	r14		
	xor		[rcx + rax + 56],	r15		

										; rbx <- индекс в таблице ReverseX, считаю как (a + 30 - N) так построена таблица. 
	mov		rbx,	r8					; rbx <- a
	add		rbx,	30					; rbx <- a + 30
	sub		rbx,	rdx					; rbx <- a + 30 - N

										; rax <- смещение в таблице ReverseX, rbx * 16 (scale = 16)
	mov		rax,	16					; rax <- 16
	push	rdx
	mul		rbx							; rax <- 16 * rbx

										; подготавливаю регистры для вызова процедуры Mul_32
	push	r8
	push	r9
	push	r10
	push	r11
	push	rsi
	push	rdi
	push	rcx
	mov		rbx,	offset ReverseX		; rbx <- адрес таблицы ReverseX
	mov		rax,	[rbx + rax]			; rax <- табличное значение по индексу (a + 30 - N)
	mov		r8,		r12					; r8, r9, r10, r11 <- Q c чертой
	mov		r9,		r13
	mov		r10,	r14
	mov		r11,	r15
	call	Mul_32						; вызов Mul_32, результат на r12, r13, r14, r15
	pop		rcx
	pop		rdi
	pop		rsi
	pop		r11
	pop		r10
	pop		r9
	pop		r8
	pop		rdx
										; прибавляю P с чертой к результату вызова процедуры Mul_32
										; P с чертой - Q с чертой * x^(a - N + 1)
	xor		r12,	rdi
	xor		r13,	rsi
	xor		r14,	r10
	xor		r15,	r11

										; r11 <- индекс в таблице ReverseXAB, считаю как (a + 29 - b) так построена таблица. 
	mov		rbx,	r8					; r11 <- a
	add		rbx,	29					; r11 <- a + 29
	sub		rbx,	r9					; r11 <- a + 29 - b

										; rax <- смещение в таблице ReverseXAB, rbx * 16 (scale = 16)
	mov		rax,	16					; rax <- 16
	push	rdx
	mul		rbx							; rax <- 16 * rbx

										; подготавливаю регистры для вызова процедуры Mul_32
	push	r8
	push	r9
	push	r10
	push	r11
	push	rsi
	push	rdi
	push	rcx
	mov		rbx,	offset ReverseXAB	; rbx <- адрес таблицы ReverseXAB
	mov		rax,	[rbx + rax]			; rax <- табличное значение по индексу (a + 29 - b)
	mov		r8,		r12					; r8, r9, r10, r11 <- P с чертой - Q с чертой * x^(a - N + 1)
	mov		r9,		r13
	mov		r10,	r14
	mov		r11,	r15
	call	Mul_32						; вызов Mul_32, результат на r12, r13, r14, r15
	pop		rcx
	pop		rdi
	pop		rsi
	pop		r11
	pop		r10
	pop		r9
	pop		r8
	pop		rdx
										; подсчет смещения для блока b
	mov		rax,	32					; rax <- 32
	push	rdx							
	mul		r9							; rax <- 32 * b
	pop		rdx

										; запись Db на место блока b
	mov		[rcx + rax],		r12
	mov		[rcx + rax + 8],	r13
	mov		[rcx + rax + 16],	r14
	mov		[rcx + rax + 24],	r15

										; вычисление Da (Da = P с чертой - Db)
	xor		r12,	rdi
	xor		r13,	rsi
	xor		r14,	r10
	xor		r15,	r11
										; подсчет смещения для блока a
	mov		rax,	20h					; rax <- 32
	push	rdx
	mul		r8							; rax <- 32 * a
	pop		rdx
										; запись Da на место блока a
	mov		[rcx + rax],		r12
	mov		[rcx + rax + 8],	r13
	mov		[rcx + rax + 16],	r14
	mov		[rcx + rax + 24],	r15


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