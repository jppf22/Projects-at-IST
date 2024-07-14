#include "api.h"

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#include "common/constants.h"
#include "common/io.h"
#include "common/pipes.h"

// These variables are global so that they are accesible in any of the functions
int req_pipe = -1;
int resp_pipe = -1;
int server_pipe = -1;
char req_path[40];
char resp_path[40];
int session_id = -1;

int ems_setup(char const* req_pipe_path, char const* resp_pipe_path, char const* server_pipe_path) {
  // create the requests pipe and assign it to the client global variable
  create_pipe(req_pipe_path);
  strncpy(req_path, req_pipe_path, strlen(req_pipe_path));
  memset(req_path + strlen(req_pipe_path), '\0', 40 - strlen(req_pipe_path));

  // create the responses pipe and assign it to the client global variable
  create_pipe(resp_pipe_path);
  strncpy(resp_path, resp_pipe_path, strlen(resp_pipe_path));
  memset(resp_path + strlen(resp_pipe_path), '\0', 40 - strlen(resp_pipe_path));

  // open the server pipe to request register
  server_pipe = open_pipe(server_pipe_path, O_WRONLY);

  // Create a register request (string with data concatenated)
  char op_code = SETUP_CODE;
  size_t buffer_size = REGISTER_BUFSIZE;  // TO-DO: find better way not using magic numbers
  char buffer[buffer_size];
  size_t buffer_iter = 0;
  memcpy(buffer + buffer_iter, &op_code, sizeof(char));
  buffer_iter += sizeof(char);
  memcpy(buffer + buffer_iter, req_path, sizeof(req_path));
  buffer_iter += sizeof(req_path);
  memcpy(buffer + buffer_iter, resp_path, sizeof(resp_path));

  // Send the register request to the server through the server_pipe
  if (write(server_pipe, buffer, buffer_size) < 0) {
    fprintf(stderr, "write error: %s\n", strerror(errno));
    return 1;
  }

  // Closes the server pipe since registration request is the only thing written to it
  close(server_pipe);

  // open the responses pipe for reading
  resp_pipe = open_pipe(resp_pipe_path, O_RDONLY);

  // open the requests pipe for writing
  req_pipe = open_pipe(req_pipe_path, O_WRONLY);

  // Receive the session id from the responses pipe
  buffer_size = sizeof(int);
  if (read(resp_pipe, buffer, buffer_size) < 0) {
    fprintf(stderr, "read error: %s\n", strerror(errno));
    return 1;
  }

  // Globally associate the session id
  memcpy(&session_id, buffer, buffer_size);

  // DEBUG
  fprintf(stderr, "[INFO] Client session %d started\n", session_id);
  return 0;
}

int ems_quit(void) {
  char op_code = QUIT_CODE;
  size_t buffer_size = 1;
  char buffer[buffer_size];
  memcpy(buffer, &op_code, buffer_size);

  // Message for the server to close its end of the communication pipes
  if (write(req_pipe, buffer, buffer_size) < 0) {
    fprintf(stderr, "write error: %s\n", strerror(errno));
    return 1;
  }

  // The client closes its end of the communication pipes
  close(req_pipe);
  close(resp_pipe);

  // unlinks the communication pipes for this client
  unlink(req_path);
  unlink(resp_path);

  return 0;
}

int ems_create(unsigned int event_id, size_t num_rows, size_t num_cols) {
  // Event creation request
  char op_code = CREATE_CODE;
  size_t buffer_size = sizeof(char) + sizeof(unsigned int) + sizeof(size_t) + sizeof(size_t);
  char buffer[buffer_size];
  int buffer_iter = 0;
  memcpy(buffer + buffer_iter, &op_code, sizeof(char));
  buffer_iter += (int)sizeof(char);
  memcpy(buffer + buffer_iter, &event_id, sizeof(unsigned int));
  buffer_iter += (int)sizeof(unsigned int);
  memcpy(buffer + buffer_iter, &num_rows, sizeof(size_t));
  buffer_iter += (int)sizeof(size_t);
  memcpy(buffer + buffer_iter, &num_cols, sizeof(size_t));

  // Send the request to the server through the reqquests pipe
  if (write(req_pipe, buffer, buffer_size) < 0) {
    fprintf(stderr, "write error: %s\n", strerror(errno));
    return 1;
  }

  // Receive the server response from the responses pipe
  buffer_size = sizeof(int);
  if (read(resp_pipe, buffer, buffer_size) < 0) {
    fprintf(stderr, "read error: %s\n", strerror(errno));
    return 1;
  }

  int response;
  memcpy(&response, buffer, sizeof(int));

  // Returns the status of the operation
  return response;
}

int ems_reserve(unsigned int event_id, size_t num_seats, size_t* xs, size_t* ys) {
  // Reservation request
  char op_code = RESERVE_CODE;
  size_t buffer_size = sizeof(char) + sizeof(unsigned int) + sizeof(size_t) + 2 * num_seats * sizeof(size_t);
  char buffer[buffer_size];
  size_t buffer_iter = 0;
  memcpy(buffer + buffer_iter, &op_code, sizeof(char));
  buffer_iter += sizeof(char);
  memcpy(buffer + buffer_iter, &event_id, sizeof(unsigned int));
  buffer_iter += sizeof(unsigned int);
  memcpy(buffer + buffer_iter, &num_seats, sizeof(size_t));
  buffer_iter += sizeof(size_t);
  memcpy(buffer + buffer_iter, xs, sizeof(size_t) * num_seats);
  buffer_iter += sizeof(size_t) * num_seats;
  memcpy(buffer + buffer_iter, ys, sizeof(size_t) * num_seats);

  // Send the reserve request to the server through the requests pipe
  if (write(req_pipe, buffer, buffer_size) < 0) {
    fprintf(stderr, "write error: %s\n", strerror(errno));
    return 1;
  }

  // Receive the server response from the responses pipe
  buffer_size = sizeof(int);
  if (read(resp_pipe, buffer, buffer_size) < 0) {
    fprintf(stderr, "read error: %s\n", strerror(errno));
    return 1;
  }

  int response;
  memcpy(&response, buffer, sizeof(int));

  // Returns the status of the operation
  return response;
}

int ems_show(int out_fd, unsigned int event_id) {
  // Event Show request
  char op_code = SHOW_CODE;
  size_t buffer_size = sizeof(char) + sizeof(int) + sizeof(unsigned int);
  char* buffer = (char*)malloc(buffer_size);
  size_t buffer_iter = 0;

  memcpy(buffer + buffer_iter, &op_code, sizeof(char));
  buffer_iter += sizeof(char);
  memcpy(buffer + buffer_iter, &event_id, sizeof(unsigned int));
  buffer_iter = 0;

  // Send the show request to the server through the requests pipe
  if (write(req_pipe, buffer, buffer_size) < 0) {
    fprintf(stderr, "write error: %s\n", strerror(errno));
    return 1;
  }

  // Receive the server response from the responses pipe
  buffer_size = sizeof(int);
  buffer = realloc(buffer, buffer_size);
  if (read(resp_pipe, buffer, buffer_size) < 0) {
    fprintf(stderr, "read error: %s\n", strerror(errno));
    return 1;
  }

  int response;
  memcpy(&response, buffer, sizeof(int));

  // In case of failed operation, no further action is taken
  if (response == 1) {
    return 1;
  }

  // Buffer for event dimensions
  buffer_size = 2 * sizeof(size_t);
  buffer = realloc(buffer, buffer_size);

  // Read the event dimensions
  if (read(resp_pipe, buffer, buffer_size) < 0) {
    fprintf(stderr, "read error: %s\n", strerror(errno));
    return 1;
  }

  size_t num_rows, num_cols;
  memcpy(&num_rows, buffer, sizeof(size_t));
  buffer_iter += sizeof(size_t);
  memcpy(&num_cols, buffer + buffer_iter, sizeof(size_t));
  buffer_iter = 0;

  // Read the seat information, according to the received dimensions, and then print it to out_fd
  for (size_t i = 1; i <= num_rows; i++) {
    for (size_t j = 1; j <= num_cols; j++) {
      unsigned int seat;
      if (read(resp_pipe, &seat, sizeof(unsigned int)) < 0) {
        fprintf(stderr, "read error: %s\n", strerror(errno));
        return 1;
      }

      if (print_uint(out_fd, seat)) {
        perror("Error writing to file descriptor");
        return 1;
      }

      if (j < num_cols) {
        if (print_str(out_fd, " ")) {
          perror("Error writing to file descriptor");
          return 1;
        }
      }
    }
    if (print_str(out_fd, "\n")) {
      perror("Error writing to file descriptor");
      return 1;
    }
  }

  free(buffer);
  return 0;
}

int ems_list_events(int out_fd) {
  // Listing of events request
  char op_code = LIST_CODE;
  size_t buffer_size = sizeof(char);
  char* buffer = (char*)malloc(buffer_size);

  // Send the list request to the server through the requests pipe
  memcpy(buffer, &op_code, sizeof(char));
  if (write(req_pipe, buffer, buffer_size) < 0) {
    fprintf(stderr, "write error: %s\n", strerror(errno));
    return 1;
  }

  // Receive the server response from the responses pipe
  buffer_size = sizeof(int);
  buffer = realloc(buffer, buffer_size);
  if (read(resp_pipe, buffer, buffer_size) < 0) {
    fprintf(stderr, "read error: %s\n", strerror(errno));
    return 1;
  }

  int response;
  memcpy(&response, buffer, sizeof(int));

  // In case of failed operation, no further action is taken
  if (response == 1) {
    return 1;
  }

  // Buffer for number of events
  buffer_size = sizeof(size_t);
  buffer = realloc(buffer, buffer_size);

  if (read(resp_pipe, buffer, buffer_size) < 0) {
    fprintf(stderr, "read error: %s\n", strerror(errno));
    return 1;
  }

  size_t num_events;
  memcpy(&num_events, buffer, sizeof(size_t));

  // Read the events information, according to the received number, and then print it to out_fd
  if (num_events == 0) {
    if (print_str(out_fd, "No events\n")) {
      perror("Error writing to file descriptor");
      return 1;
    }
  } else {
    for (size_t i = 0; i < num_events; i++) {
      unsigned int id;

      if (read(resp_pipe, &id, sizeof(unsigned int)) < 0) {
        fprintf(stderr, "read error: %s\n", strerror(errno));
        return 1;
      }

      if (print_str(out_fd, "Event: ")) {
        perror("Error writing to file descriptor");
        return 1;
      }

      if (print_uint(out_fd, id)) {
        perror("Error writing to file descriptor");
        return 1;
      }

      if (print_str(out_fd, "\n")) {
        perror("Error writing to file descriptor");
        return 1;
      }
    }
  }

  free(buffer);
  return 0;
}
