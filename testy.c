#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define MAX_BUFFER 1024

#define SYSFS_FILE_A1 "/sys/kernel/sykt/kjaa1"
#define SYSFS_FILE_A2 "/sys/kernel/sykt/kjaa2"
#define SYSFS_FILE_W "/sys/kernel/sykt/kjaw"
#define SYSFS_FILE_L "/sys/kernel/sykt/kjal"
#define SYSFS_FILE_B "/sys/kernel/sykt/kjab"

#define MAX_RETRIES 10
#define WAIT_TIME_MS 100

unsigned int read_from_file(char *filePath)
{
	char buffer[MAX_BUFFER];
	int file = open(filePath, O_RDONLY);
	if (file < 0)
	{
		printf("Open %s - error number %d\n", filePath, errno);
		exit(2);
	}
	int n = read(file, buffer, MAX_BUFFER);
	close(file);
	return strtoul(buffer, NULL, 16);
}

int write_to_file(char *filePath, unsigned int input)
{
	char buffer[MAX_BUFFER];
	FILE *file = fopen(filePath, "w");
	if (file == NULL)
	{
		printf("Open %s - error number %d\n", filePath, errno);
		exit(2);
	}
	snprintf(buffer, MAX_BUFFER, "%x", input);
	fwrite(buffer, strlen(buffer), 1, file);
	fclose(file);
	return 0;
}

int multiplying(int a1, int a2)
{

	unsigned int status;
	unsigned int result;
	unsigned int retry_count = 0;

	write_to_file(SYSFS_FILE_A1, a1);
	write_to_file(SYSFS_FILE_A2, a2);

	do
	{
		status = read_from_file(SYSFS_FILE_B);
		if (status == 1)
		{
			retry_count++;
			if (retry_count >= MAX_RETRIES)
			{
				printf("Przekroczono maksymalną liczbę powtórzeń(10). Przerwanie pętli.\n");
				break;
			}
			usleep(WAIT_TIME_MS * 1000); // Poczekaj przed kolejnym odczytem
		}
	} while (status == 1);

	printf("A1=%x, A2=%x, W=%x, L=%x, B=%x\n", read_from_file(SYSFS_FILE_A1), read_from_file(SYSFS_FILE_A2), read_from_file(SYSFS_FILE_W), read_from_file(SYSFS_FILE_L), read_from_file(SYSFS_FILE_B));

	return 0;
}

int main(void)
{

	printf("Test 1: 1*0 = 0\n");
	multiplying(1, 0);

	printf("Test 2: 1*1 = 1 (0x1)\n");
	multiplying(1, 1);

	printf("Test 3.1(Commutation#1): 3*4 = 12 (0xC)\n");
	multiplying(3, 4);

	printf("Test 3.2(Commutation#2): 4*3 = 12 (0xC)\n");
	multiplying(4, 3);

	printf("Test 4: 96*53 = 5088 (0x13E0)\n");
	multiplying(96, 53);

	printf("Test 5: 305*289 = 88145 (0x15851)\n");
	multiplying(305, 289);

	printf("Test 6(Zero Shifting): 15(0xf) * 256(0x100) = 240(0xF00)\n");
	multiplying(15, 256);

	printf("Test 7: Overflow\n");
	multiplying(0xFFFFFF, 0xFFFFFF);

	return 0;
}
