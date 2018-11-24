#include <stdio.h>

// Умножение на x
int mulx_32(int a)
{
	int a1, a2;
	a1 = a << 1;
	a2 = (a >> 31) & 0x0000008D;
	return a1 ^ a2;
}

// Вспомогательная функция для построения операции умножения произвольных элементов
// Умножает sum на x и прибавляет произведение a на старший бит b  
int mulstep_32(int sum, int a, int b)
{
	int a1, a2;
	a1 = mulx_32(sum); // sum * x
	a2 = a & (b >> 31); // a * старший (знаковый) бит b

	return a1 ^ a2;
}

// Умножение
unsigned int mul_32(unsigned int a, unsigned int b)
{
	int sum = 0;
	for (int i = 0; i < 32; i++)
	{
		sum = mulstep_32(sum, a, b); // шаг умножения a на старший бит b
		b = b << 1; // переход к следующему биту
	}
	return sum;
}

// Печатает двоичное представление числа.
void printbin(unsigned int n) {
	while (n) {
		if ((n >> 31) & 1)
			printf("1");
		else
			printf("0");

		n <<= 1;
	}
	printf("\n");
}

//a^(-1) = a^(4294967294)
unsigned int reverse_32(unsigned int a) {
	unsigned int Y;
	unsigned int Z;
	Z = mul_32(a, a);	// Z = a^2
	Y = Z;				// Y = a^2
	Z = mul_32(Z, Z);	// Z = a^4
	Y = mul_32(Y, Z);	// Y = a^6
	Z = mul_32(Z, Z);	// Z = a^8
	Y = mul_32(Y, Z);	// Y = a^14
	Z = mul_32(Z, Z);	// Z = a^16
	Y = mul_32(Y, Z);	// Y = a^30
	Z = mul_32(Z, Z);	// Z = a^32
	Y = mul_32(Y, Z);	// Y = a^62
	Z = mul_32(Z, Z);	// Z = a^64
	Y = mul_32(Y, Z);	// Y = a^126
	Z = mul_32(Z, Z);	// Z = a^128
	Y = mul_32(Y, Z);	// Y = a^254
	Z = mul_32(Z, Z);	// Z = a^256
	Y = mul_32(Y, Z);	// Y = a^510
	Z = mul_32(Z, Z);	// Z = a^512
	Y = mul_32(Y, Z);	// Y = a^1022
	Z = mul_32(Z, Z);	// Z = a^1024
	Y = mul_32(Y, Z);	// Y = a^2046
	Z = mul_32(Z, Z);	// Z = a^2048
	Y = mul_32(Y, Z);	// Y = a^4094
	Z = mul_32(Z, Z);	// Z = a^4096
	Y = mul_32(Y, Z);	// Y = a^8190
	Z = mul_32(Z, Z);	// Z = a^8192
	Y = mul_32(Y, Z);	// Y = a^16382
	Z = mul_32(Z, Z);	// Z = a^16384
	Y = mul_32(Y, Z);	// Y = a^32766
	Z = mul_32(Z, Z);	// Z = a^32768
	Y = mul_32(Y, Z);	// Y = a^65534
	Z = mul_32(Z, Z);	// Z = a^65536
	Y = mul_32(Y, Z);	// Y = a^131070
	Z = mul_32(Z, Z);	// Z = a^131072
	Y = mul_32(Y, Z);	// Y = a^262142
	Z = mul_32(Z, Z);	// Z = a^262144
	Y = mul_32(Y, Z);	// Y = a^524286
	Z = mul_32(Z, Z);	// Z = a^524288
	Y = mul_32(Y, Z);	// Y = a^1048574
	Z = mul_32(Z, Z);	// Z = a^1048576
	Y = mul_32(Y, Z);	// Y = a^2097150
	Z = mul_32(Z, Z);	// Z = a^2097152
	Y = mul_32(Y, Z);	// Y = a^4194302
	Z = mul_32(Z, Z);	// Z = a^4194304
	Y = mul_32(Y, Z);	// Y = a^8388606
	Z = mul_32(Z, Z);	// Z = a^8388608
	Y = mul_32(Y, Z);	// Y = a^16777214
	Z = mul_32(Z, Z);	// Z = a^16777216
	Y = mul_32(Y, Z);	// Y = a^33554430
	Z = mul_32(Z, Z);	// Z = a^33554432
	Y = mul_32(Y, Z);	// Y = a^67108862
	Z = mul_32(Z, Z);	// Z = a^67108864
	Y = mul_32(Y, Z);	// Y = a^134217726
	Z = mul_32(Z, Z);	// Z = a^134217728
	Y = mul_32(Y, Z);	// Y = a^268435454
	Z = mul_32(Z, Z);	// Z = a^268435456
	Y = mul_32(Y, Z);	// Y = a^536870910
	Z = mul_32(Z, Z);	// Z = a^536870912
	Y = mul_32(Y, Z);	// Y = a^1073741822
	Z = mul_32(Z, Z);	// Z = a^1073741824
	Y = mul_32(Y, Z);	// Y = a^2147483646
	Z = mul_32(Z, Z);	// Z = a^2147483648
	Y = mul_32(Y, Z);	// Y = a^4294967294

	return(Y);
}

int main()
{
	//степени икса с 29 по 0
	unsigned int vals[30] = {			0b100000000000000000000000000000,
										0b10000000000000000000000000000,
										0b1000000000000000000000000000,
										0b100000000000000000000000000,
										0b10000000000000000000000000,
										0b1000000000000000000000000,
										0b100000000000000000000000,
										0b10000000000000000000000,
										0b1000000000000000000000,
										0b100000000000000000000,
										0b10000000000000000000,
										0b1000000000000000000,
										0b100000000000000000,
										0b10000000000000000,
										0b1000000000000000,
										0b100000000000000,
										0b10000000000000,
										0b1000000000000,
										0b100000000000,
										0b10000000000,
										0b1000000000,
										0b100000000,
										0b10000000,
										0b1000000,
										0b100000,
										0b10000,
										0b1000,
										0b100,
										0b10,
										0b1};

	unsigned int a, res;

	//подсчет и выввод степеней икса с -29 по 0
	for (int i = 0; i < 30; i++)
	{
		a = vals[i];
		res = reverse_32(a);
		printf("reverse:\n");
		printf("%u\n", res);
		printf("%X\n", res);
		printbin(res);
		printf("a * a^-1 :\n");
		res = mul_32(a, res);
		printf("%u\n", res);
		printf("%X\n", res);
		printbin(res);
		printf("--------------------------------------\n");
	}
	//подсчет и выввод 1/(1-x^(a-b)) где a - b с -29 по -1
	for (int i = 0; i < 29; i++)
	{
		a = vals[i];
		res = reverse_32(a);
		res ^= 1;
		res = reverse_32(res);
		printf("%u\n", res);
		printf("%X\n", res);
		printbin(res);
		printf("--------------------------------------\n");
	}
	return 0;
}
