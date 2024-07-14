#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <pthread.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#include "common/constants.h"
#include "common/io.h"
#include "common/pipes.h"
#include "operations.h"
#include "queue.h"
#include "threads.h"

// the flag that keeps track of SIGUSR1 signal calls
static int flag_sigusr1 = 0;

static void sig_handler(int sig) {
  if (sig == SIGUSR1) {
    if (signal(SIGUSR1, sig_handler) == SIG_ERR) {
      exit(EXIT_FAILURE);
    }

    // DEBUG
    fprintf(stderr, "[Register thread] Caught SIGUSR1\n");

    flag_sigusr1 = 1;
    return;
  }
}

int main(int argc, char* argv[]) {
  if (argc < 2 || argc > 3) {
    fprintf(stderr, "Usage: %s\n <pipe_path> [delay]\n", argv[0]);
    return 1;
  }

  char* endptr;
  unsigned int state_access_delay_us = STATE_ACCESS_DELAY_US;
  if (argc == 3) {
    unsigned long int delay = strtoul(argv[2], &endptr, 10);

    if (*endptr != '\0' || delay > UINT_MAX) {
      fprintf(stderr, "Invalid delay value or value too large\n");
      return 1;
    }

    state_access_delay_us = (unsigned int)delay;
  }

  if (ems_init(state_access_delay_us)) {
    fprintf(stderr, "Failed to initialize EMS\n");
    return 1;
  }

  // Register the signal handler for SIGUSR1
  if (signal(SIGUSR1, sig_handler) == SIG_ERR) {
    exit(EXIT_FAILURE);
  }

  // initialize the server by creating the client register pipe
  char* fifo_register = argv[1];
  create_pipe(fifo_register);

  //  create all the threads
  //  the threads dequeue a client and work with it until the end of the session
  //  when the session ends, they simply dequeue another client or wait for a client to appear

  // initialize the register requests queue
  struct Queue* req_queue = create_queue();

  // Start the threads with the necessary information: a pointer to the queue and the session_id they represent
  for (int i = 1; i <= MAX_SESSION_COUNT; i++) {
    pthread_t tid;
    struct Thread_Info* thread_info = (struct Thread_Info*)malloc(sizeof(struct Thread_Info));
    thread_info->ptr_req_queue = &req_queue;
    thread_info->session_id = i;
    pthread_create(&tid, NULL, thread_routine, (void*)thread_info);
  }

  // open pipe for reading
  // HACK: O_RDWR flag is used to ensure the pipe always as a writer (even though it never writes from server side)
  int register_pipe = open_pipe(fifo_register, O_RDWR);

  while (1) {
    if (flag_sigusr1) {
      ems_status();
      flag_sigusr1 = 0;
    }

    size_t buffer_size = REGISTER_BUFSIZE;
    char* buffer = (char*)malloc(buffer_size);
    if (buffer == NULL) {
      fprintf(stderr, "Could not allocate memory\n");
      return 1;
    }

    // DEBUG
    // fprintf(stderr, "Before reading from register_piper\n");

    ssize_t bytes_read = read(register_pipe, buffer, buffer_size);
    if (bytes_read < 0) {
      // This condition will trigger whenever a signal is received, such as SIGUSR1.
      // The handler changes the flag, so the flag condition
      // at the beginning of the loop must be met as quickly as possible
      if (errno == EINTR) {
        // DEBUG
        // fprintf(stderr, "read interrupted by a signal being thrown: %s\n", strerror(errno));
        free(buffer);
        continue;
      } else {
        fprintf(stderr, "read error: %s\n", strerror(errno));
        return 1;
      }
    } else if (bytes_read == 0) {
      // DEBUG
      // fprintf(stderr, "pipe closed on the other end");
      free(buffer);
      continue;
    } else {
      // Request was successfuly read, it is then enqueued
      enqueue(req_queue, buffer);
    }
  }

  // MISSING: way for server to end / handling of SIGINT or SIGTERM
  ems_terminate();
}