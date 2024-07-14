#ifndef THREADS_H
#define THREADS_H

#include "queue.h"

struct Thread_Info {
  struct Queue** ptr_req_queue;  /// pointer to the client's request queue
  int session_id;                /// contains the associated session_id for this thread
};

/// Routine that handles client requests, it is executed by a thread
/// @param args pointer to the Thread_Info struct containing session information
void* thread_routine(void* args);

/// Handles client requests based on the operation codes received
/// @param req registration data received from the client
/// @param session_id integer that represents the session ID associated with the client
/// @return 0 if the client requests are handled successfully, 1 if an error occurs
int handle_client(char* req, int session_id);

/// Reads the next client operation from the specified pipe (single byte)
/// @param req_pipe file descriptor of the pipe from which the data will be read
/// @param buffer_requests buffer that stores the OP_CODE of the request
/// @return 0 if the read operation is successful and the byte read is not QUIT_CODE, else 1
int get_next_client_operation(int req_pipe, char* buffer_requests);

#endif