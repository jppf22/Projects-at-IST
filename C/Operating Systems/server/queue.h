#ifndef QUEUE_H
#define QUEUE_H

#include <pthread.h>

struct Node {
  char* req;  /// Client Request
  struct Node* next;
};

struct Queue {
  struct Node* first;                       /// First request in the queue
  struct Node* last;                        /// Last request in the queue
  int count;                                /// Number of requests in the queue
  pthread_mutex_t queue_mutex;              /// Mutex to protect the queue
  pthread_cond_t can_enqueue, can_dequeue;  /// Condition variables to synchronize operations on the queue
};

/// Creates a new request queue.
/// @return Newly created request queue, NULL on failure
struct Queue* create_queue();

/// Checks if the queue is currently empty
/// @param queue Queue to be verified
/// @return 1 if the queue is empty, 0 otherwise
int is_empty_queue(struct Queue* queue);

/// Adds a request to the end of the queue
/// @param queue Queue to be modified
/// @param req Request to be stored in the new node
/// @return 0 if the node was added successfully, 1 otherwise.
int enqueue(struct Queue* queue, char* req);

/// Removes the oldest request from the queue
/// @param queue Queue to be modified
/// @return Request to be retrieved
char* dequeue(struct Queue* queue);

/// Frees all memory associated with the queue
/// @param queue Queue to be freed
void free_queue(struct Queue* queue);

#endif