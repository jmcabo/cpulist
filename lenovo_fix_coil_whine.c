
#include <stdio.h>
#include <fcntl.h>

#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>


int disable_C_states_greater_than_C1_and_keep(int latency) {
    int fd = 0;
    printf("setting latency to %d us\n", latency);
    fd = open("/dev/cpu_dma_latency", O_WRONLY);
    if (fd < 0) {
        perror("open /dev/cpu_dma_latency");
        return 1;
    }
    if (write(fd, &latency, sizeof(latency)) != sizeof(latency)) {
        perror("write to /dev/cpu_dma_latency");
        return 1;
    }
    while (1) pause();
}

int main(int argc, char **argv) {
    int32_t l;
    int fd;
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <latency in us> \n", argv[0]);
        fprintf(stderr, "Example:   lenovo_fix_coil_whine 250 \n\n");
        return 2;
    }
    l = atoi(argv[1]);

    disable_C_states_greater_than_C1_and_keep(l);
}


