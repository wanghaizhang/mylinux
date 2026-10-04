#include <stdio.h>
#include <unistd.h>

int main(void)
{
    printf("MyServer started.\n");
    printf("PID: %d\n", getpid());

    while (1) {
        sleep(60);
    }

    return 0;
}
