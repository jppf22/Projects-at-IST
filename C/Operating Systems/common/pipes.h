#ifndef PIPES_H
#define PIPES_H

/// Creates a pipe with the given path
/// @param pipe_path The path to create the pipe at
void create_pipe(char const* pipe_path);

/// Opens a pipe with given flags
/// @param pipe_path The path of the pipe
/// @param flag flags to open pipe with
int open_pipe(char const* pipe_path, int flag);

#endif