#include "threads.h"

#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#include "common/constants.h"
#include "common/pipes.h"
#include "operations.h"
#include "queue.h"

void* thread_routine(void* args) {
  struct Thread_Info* thread_info = (struct Thread_Info*)args;
  int session_id = thread_info->session_id;

  // Prevents this thread from reacting to SIGUSR1 signal calls
  sigset_t set;
  sigemptyset(&set);
  sigaddset(&set, SIGUSR1);
  pthread_sigmask(SIG_BLOCK, &set, NULL);

  while (1) {
    // DEBUG
    // fprintf(stderr, ""[INFO thread %d] Inside thread: before dequeueing\n", session_id);

    // Retrieves a registration request from the queue (blocks if none available)
    char* req = dequeue(*(thread_info->ptr_req_queue));

    // DEBUG
    // fprintf(stderr, ""[INFO thread %d] Before handling client with request: ", session_id);
    /*
    for(int i=0; i < 81; i++){
        fprintf(stderr,"%02X ", (unsigned char) req[i]);
    }
    fprintf(stderr,"'\n");
    */

    // Attends to client requests until session is ended
    handle_client(req, session_id);

    free(req);
  }

  // Since server termination is missing, this is never used
  free(thread_info);
}

int handle_client(char* req, int session_id) {
  // Estabilish connections to client and send session_id

  // Register request info
  int req_iter = 1;
  char req_path[40];
  char resp_path[40];

  // Reads the paths of communication pipes from the request
  memcpy(req_path, req + req_iter, 40);
  req_iter += 40;
  memcpy(resp_path, req + req_iter, 40);

  // Opens the pipes to communicate with client
  int resp_pipe = open_pipe(resp_path, O_WRONLY);
  int req_pipe = open_pipe(req_path, O_RDONLY);

  // Sends the assigned session_id back to the client
  char buffer_register[sizeof(int)];
  memcpy(buffer_register, &session_id, sizeof(int));
  if (write(resp_pipe, buffer_register, sizeof(int)) < 0) {
    fprintf(stderr, "read error: %s\n", strerror(errno));
    return 1;
  }

  // Read from requests pipe
  char* buffer_requests = (char*)malloc(sizeof(char));
  if (buffer_requests == NULL) {
    fprintf(stderr, "Could not allocate memory\n");
    return 1;
  }

  char* buffer_response = NULL;
  size_t buffer_requests_size = 0;
  size_t buffer_response_size = 0;

  size_t buffer_iter = 0;

  // While the next operation isn't OP_CODE2 (to end the session), handle it
  while (get_next_client_operation(req_pipe, buffer_requests) != 1) {
    switch (buffer_requests[0]) {
      case CREATE_CODE: {
        buffer_requests_size = sizeof(unsigned int) + sizeof(size_t) * 2;
        buffer_response_size = sizeof(int);

        buffer_requests = realloc(buffer_requests, buffer_requests_size);
        if (buffer_requests == NULL) {
          fprintf(stderr, "Could not allocate memory\n");
          return 1;
        }

        buffer_response = (char*)malloc(buffer_response_size);
        if (buffer_response == NULL) {
          fprintf(stderr, "Could not allocate memory\n");
          return 1;
        }

        // Read the creation request
        if (read(req_pipe, buffer_requests, buffer_requests_size) < 0) {
          fprintf(stderr, "read error: %s\n", strerror(errno));
          return 1;
        }

        // Deserialize creation request information
        unsigned int event_id;
        size_t num_rows, num_cols;

        memcpy(&event_id, buffer_requests, sizeof(unsigned int));
        buffer_iter += sizeof(unsigned int);
        memcpy(&num_rows, buffer_requests + buffer_iter, sizeof(size_t));
        buffer_iter += sizeof(size_t);
        memcpy(&num_cols, buffer_requests + buffer_iter, sizeof(size_t));
        buffer_iter = 0;

        // DEBUG
        fprintf(stderr, "[INFO thread %d]: Wants to create event with %u id, %zu rows and %zu cols.\n", session_id,
                event_id, num_rows, num_cols);

        // Execute the event creation operation
        int result;
        result = ems_create(event_id, num_rows, num_cols);

        // Serialize and send the result of the operation
        memcpy(buffer_response, &result, sizeof(int));
        if (write(resp_pipe, buffer_response, buffer_response_size) < 0) {
          fprintf(stderr, "write error: %s\n", strerror(errno));
          return 1;
        }
        break;
      }
      case RESERVE_CODE: {
        buffer_response_size = sizeof(int);
        buffer_response = (char*)malloc(buffer_response_size);
        if (buffer_response == NULL) {
          fprintf(stderr, "Could not allocate memory\n");
          return 1;
        }

        buffer_requests_size = sizeof(unsigned int) + sizeof(size_t);
        buffer_requests = realloc(buffer_requests, buffer_requests_size);

        // Read the requested reservation id and dimensions
        if (read(req_pipe, buffer_requests, buffer_requests_size) < 0) {
          fprintf(stderr, "read error: %s\n", strerror(errno));
          return 1;
        }

        // Deserialize requested reservation id and dimensions
        unsigned int event_id;
        size_t num_seats;

        memcpy(&event_id, buffer_requests, sizeof(unsigned int));
        buffer_iter += sizeof(unsigned int);
        memcpy(&num_seats, buffer_requests + buffer_iter, sizeof(size_t));
        buffer_iter = 0;

        // DEBUG
        fprintf(stderr, "[INFO thread %d]: Wants to reserve %zu seats on event %u\n", session_id, num_seats, event_id);

        // Allocate seat buffer according to the dimensions
        buffer_requests_size = sizeof(size_t) * num_seats * 2;
        buffer_requests = realloc(buffer_requests, buffer_requests_size);

        // Read the requested reservation seats
        if (read(req_pipe, buffer_requests, buffer_requests_size) < 0) {
          fprintf(stderr, "read error: %s\n", strerror(errno));
          return 1;
        }

        // Deserialize the requested seats
        size_t* xs = (size_t*)malloc(sizeof(size_t) * num_seats);
        if (xs == NULL) {
          fprintf(stderr, "Could not allocate memory\n");
          return 1;
        }

        size_t* ys = (size_t*)malloc(sizeof(size_t) * num_seats);
        if (ys == NULL) {
          fprintf(stderr, "Could not allocate memory\n");
          return 1;
        }

        for (size_t i = 0; i < num_seats; i++) {
          memcpy(xs + buffer_iter, buffer_requests + (buffer_iter * sizeof(size_t)), sizeof(size_t));
          memcpy(ys + buffer_iter, buffer_requests + ((buffer_iter + num_seats) * sizeof(size_t)), sizeof(size_t));
          buffer_iter += 1;
        }
        buffer_iter = 0;

        // Execute the event reservation operation
        int result;
        result = ems_reserve(event_id, num_seats, xs, ys);

        // Serialize and send the result of the operation
        memcpy(buffer_response, &result, sizeof(int));
        if (write(resp_pipe, buffer_response, buffer_response_size) < 0) {
          fprintf(stderr, "write error: %s\n", strerror(errno));
          return 1;
        }

        free(xs);
        free(ys);
        break;
      }
      case SHOW_CODE: {
        buffer_requests_size = sizeof(unsigned int);
        buffer_requests = realloc(buffer_requests, buffer_requests_size);

        // Read the event show request
        if (read(req_pipe, buffer_requests, buffer_requests_size) < 0) {
          fprintf(stderr, "read error: %s\n", strerror(errno));
          return 1;
        }

        // Deserialize show request information
        unsigned int event_id;
        memcpy(&event_id, buffer_requests, sizeof(unsigned int));

        // DEBUG
        fprintf(stderr, "[INFO thread %d]: Wants to show event %d\n", session_id, event_id);

        char* buffer_event_info = NULL;
        size_t buffer_event_info_size;

        // Execute the show event operation and create a buffer with the requested information
        int result = ems_show(event_id, &buffer_event_info, &buffer_event_info_size);

        buffer_response = (char*)malloc(sizeof(int));
        if (buffer_response == NULL) {
          fprintf(stderr, "Could not allocate memory\n");
          return 1;
        }

        // Serialize and send result of operation
        memcpy(buffer_response, &result, sizeof(int));
        if (write(resp_pipe, buffer_response, sizeof(int)) < 0) {
          fprintf(stderr, "write error: %s\n", strerror(errno));
          return 1;
        }

        // If the result was sucessful, serialize and send the requested information
        if (result == 0) {
          if (write(resp_pipe, buffer_event_info, buffer_event_info_size) < 0) {
            fprintf(stderr, "write error: %s\n", strerror(errno));
            return 1;
          }
        }

        free(buffer_event_info);
        break;
      }
      case LIST_CODE: {
        // DEBUG
        fprintf(stderr, "[INFO thread %d]: Wants to list events\n", session_id);

        char* buffer_list_info = NULL;
        size_t buffer_list_info_size;

        // Execute the listing of events and create a buffer with the requested information
        int result = ems_list_events(&buffer_list_info, &buffer_list_info_size);

        buffer_response = (char*)malloc(sizeof(int));
        if (buffer_response == NULL) {
          fprintf(stderr, "Could not allocate memory\n");
          return 1;
        }

        // Serialize and send result of operation
        memcpy(buffer_response, &result, sizeof(int));
        if (write(resp_pipe, buffer_response, sizeof(int)) < 0) {
          fprintf(stderr, "write error: %s\n", strerror(errno));
          return 1;
        }

        // If the result was sucessful, serialize and send the requested information
        if (result == 0) {
          if (write(resp_pipe, buffer_list_info, buffer_list_info_size) < 0) {
            fprintf(stderr, "write error: %s\n", strerror(errno));
            return 1;
          }
        }

        free(buffer_list_info);
        break;
      }
    }

    buffer_iter = 0;
  }

  // After receiving the termination request, closes the server end of the communication pipes
  close(resp_pipe);
  close(req_pipe);
  free(buffer_requests);
  free(buffer_response);

  return 0;
}

// Receives the next operation OPCODE
int get_next_client_operation(int req_pipe, char* buffer_requests) {
  if (read(req_pipe, buffer_requests, 1) < 0) {
    fprintf(stderr, "read error: %s\n", strerror(errno));
    return 1;
  }

  if (buffer_requests[0] == QUIT_CODE) {
    return 1;
  }

  return 0;
}
