// 2021 June 2
// Author: Abraham Silberschatz  in book Operating System Concepts 8th Edition p.170
// Demo using how to speed up sum of sequence integer.
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

struct partition {
    int start;
    int end;
};

// Function to check if a number is prime
int is_prime(int n) {
    if (n <= 1) return 0;
    for (int i = 2; i * i <= n; i++) {
        if (n % i == 0) return 0;
    }
    return 1;
}

// Function executed by the threads to find and print prime numbers in their partition
void *find_primes(void *param) {
    struct partition *p = (struct partition *)param;
    int start = p->start;
    int end = p->end;

    for (int i = start; i <= end; i++) {
        if (is_prime(i)) {
            printf("Prime number found by thread %lu: %d\n", pthread_self(), i);
        }
    }
    pthread_exit(NULL);
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <integer>\n", argv[0]);
        return 1;
    }

    int n = atoi(argv[1]);
    if (n < 2) {
        printf("No prime numbers less than or equal to %d\n", n);
        return 0;
    }

    int num_threads = 2; // You can adjust the number of threads
    pthread_t tid[num_threads];
    pthread_attr_t attr;
    pthread_attr_init(&attr);

    // Determine the partitions for each thread
    int range = n;
    int partition_size = (range + num_threads - 1) / num_threads; // Ceiling division

    struct partition partitions[num_threads];
    int start = 2;
    for (int i = 0; i < num_threads; i++) {
        partitions[i].start = start;
        partitions[i].end = start + partition_size - 1;
        if (partitions[i].end > n) {
            partitions[i].end = n;
        }
        start = partitions[i].end + 1;

        if (partitions[i].start <= partitions[i].end) {
            if (pthread_create(&tid[i], &attr, find_primes, (void *)&partitions[i]) != 0) {
                perror("pthread_create");
                return 1;
            }
        }
    }

    // Wait for the threads to finish
    for (int i = 0; i < num_threads; i++) {
        if (partitions[i].start <= partitions[i].end) {
            if (pthread_join(tid[i], NULL) != 0) {
                perror("pthread_join");
                return 1;
            }
        }
    }

    pthread_attr_destroy(&attr);
    return 0;
}
