// 2021 June 2
// Author: Abraham Silberschatz  in book Operating System Concepts 8th Edition p.170
// Demo using how to speed up sum of sequence integer.
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/resource.h>

int min, max; /* this data is shared by the thread(s) */
float ave;
int *a;       /* the shared array (dynamically allocated) */
int size;

void *average_runner(void *param); /* threads call this function */
void *maximum_runner(void *param);
void *minimum_runner(void *param);

long measure_cpu_time() {
    struct rusage usage;
    getrusage(RUSAGE_SELF, &usage);
    return (usage.ru_utime.tv_sec * 1000000LL + usage.ru_utime.tv_usec);
}

int main(int argc, char *argv[]) {
    if (argc <= 1) {
        fprintf(stderr, "Usage: %s <integer1> <integer2> ...\n", argv[0]);
        return 1;
    }

    size = argc - 1;
    a = (int *)malloc(size * sizeof(int));
    if (a == NULL) {
        perror("Failed to allocate memory for the array");
        return 1;
    }

    // Populate the array from command line arguments
    for (int i = 0; i < size; i++) {
        a[i] = atoi(argv[i + 1]);
    }

    pthread_t tid[3]; /* the thread identifier */
    pthread_attr_t attr; /* set of thread attributes */

    /* set the default attributes of the thread */
    pthread_attr_init(&attr);

    long start_cpu = measure_cpu_time();

    /* create the threads */
    if (pthread_create(&tid[0], &attr, average_runner, NULL) != 0) {
        perror("Failed to create average thread");
        free(a);
        return 1;
    }
    if (pthread_create(&tid[1], &attr, maximum_runner, NULL) != 0) {
        perror("Failed to create maximum thread");
        free(a);
        return 1;
    }
    if (pthread_create(&tid[2], &attr, minimum_runner, NULL) != 0) {
        perror("Failed to create minimum thread");
        free(a);
        return 1;
    }

    /* wait for the threads to exit */
    if (pthread_join(tid[0], NULL) != 0) {
        perror("Failed to join average thread");
    }
    if (pthread_join(tid[1], NULL) != 0) {
        perror("Failed to join maximum thread");
    }
    if (pthread_join(tid[2], NULL) != 0) {
        perror("Failed to join minimum thread");
    }

    long end_cpu = measure_cpu_time();
    long cpu_time_us = end_cpu - start_cpu;

    printf("The average value is: %.2f\n", ave);
    printf("The maximum value is: %d\n", max);
    printf("The minimum value is: %d\n", min);
    printf("\nCPU time used: %ld microseconds\n", cpu_time_us);

    free(a); // Free the dynamically allocated memory
    return 0;
}

/* The thread will execute in this function to calculate the average */
void *average_runner(void *param) {
    if (size > 0) {
        float sum = 0;
        for (int i = 0; i < size; i++) {
            sum += a[i];
        }
        ave = sum / size;
    } else {
        ave = 0; // Handle the case of an empty array
    }
    pthread_exit(NULL);
}

/* The thread will execute in this function to find the maximum */
void *maximum_runner(void *param) {
    if (size > 0) {
        max = a[0];
        for (int i = 1; i < size; i++) {
            if (a[i] > max) {
                max = a[i];
            }
        }
    }
    pthread_exit(NULL);
}

/* The thread will execute in this function to find the minimum */
void *minimum_runner(void *param) {
    if (size > 0) {
        min = a[0];
        for (int i = 1; i < size; i++) {
            if (a[i] < min) {
                min = a[i];
            }
        }
    }
    pthread_exit(NULL);
}
