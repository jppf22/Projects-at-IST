#include "queue.h"

#include <stdio.h>
#include <stdlib.h>

#include "common/constants.h"

struct Queue* create_queue() {
  struct Queue* queue = (struct Queue*)malloc(sizeof(struct Queue));
  if (queue == NULL) {
    return NULL;
  }
  queue->first = queue->last = NULL;

  queue->count = 0;

  pthread_mutex_init(&(queue->queue_mutex), NULL);
  pthread_cond_init(&(queue->can_dequeue), NULL);
  pthread_cond_init(&(queue->can_enqueue), NULL);

  return queue;
}

int is_empty_queue(struct Queue* queue) {
  if (queue == NULL) {
    return 1;
  }
  return (queue->first == NULL);
}

int enqueue(struct Queue* queue, char* req) {
  if (queue == NULL) return 1;

  struct Node* new_node = (struct Node*)malloc(sizeof(struct Node));
  if (new_node == NULL) return 1;
  new_node->req = req;
  new_node->next = NULL;

  pthread_mutex_lock(&(queue->queue_mutex));
  while (queue->count >= MAX_SESSION_COUNT) {
    pthread_cond_wait(&(queue->can_enqueue), &(queue->queue_mutex));
  }

  if (is_empty_queue(queue)) {
    queue->first = queue->last = new_node;
  } else {
    queue->last->next = new_node;
    queue->last = new_node;
  }

  // DEBUG
  // fprintf(stderr, "[Register Thread] enqueued request with OPCODE %d\n", req[0]);

  queue->count++;
  pthread_cond_signal(&(queue->can_dequeue));
  pthread_mutex_unlock(&(queue->queue_mutex));

  return 0;
}

char* dequeue(struct Queue* queue) {
  pthread_mutex_lock(&(queue->queue_mutex));
  while (queue->count == 0) {
    pthread_cond_wait(&(queue->can_dequeue), &(queue->queue_mutex));
  }

  struct Node* old_first = queue->first;
  char* req =
      old_first
          ->req;  // this will not be explicily freed, this is only freed when the thread deserializes the instructions

  queue->first = queue->first->next;
  if (queue->first == NULL) {
    queue->last = NULL;
  }

  free(old_first);  // old_first->req is freed on the thread

  // DEBUG
  // fprintf(stderr,"[Register Thread] dequeued request with OPCODE %d\n", req[0]);

  queue->count--;
  pthread_cond_signal(&(queue->can_enqueue));
  pthread_mutex_unlock(&(queue->queue_mutex));
  return req;
}

// Since server termination is missing, this is never used
void free_queue(struct Queue* queue) {
  /*
  while (!isEmpty(queue)) {
      free(dequeue(queue));
  }
  */
  free(queue);
}
