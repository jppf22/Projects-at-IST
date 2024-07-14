#include "pipes.h"

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

void create_pipe(char const* pipe_path) {
  // If a pipe already existed with that name, unlink it
  if (unlink(pipe_path) != 0 && errno != ENOENT) {
    fprintf(stderr, "[ERR]: unlink(%s) failed: %s\n", pipe_path, strerror(errno));
    exit(EXIT_FAILURE);
  }

  // create the pipe
  if (mkfifo(pipe_path, 0640) != 0) {
    fprintf(stderr, "[ERR]: mkfifo failed: %s\n", strerror(errno));
    exit(EXIT_FAILURE);
  }
}

int open_pipe(char const* pipe_path, int flag) {
  // Open the pipe with the given flags
  int pipe = open(pipe_path, flag);
  if (pipe == -1) {
    fprintf(stderr, "[ERR]: open failed: %s\n", strerror(errno));
    exit(EXIT_FAILURE);
  }
  return pipe;
}
