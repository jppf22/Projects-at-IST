#ifndef SERVER_OPERATIONS_H
#define SERVER_OPERATIONS_H

#include <stddef.h>

/// Initializes the EMS state.
/// @param delay_us Delay in microseconds.
/// @return 0 if the EMS state was initialized successfully, 1 otherwise.
int ems_init(unsigned int delay_us);

/// Destroys the EMS state.
int ems_terminate();

/// Creates a new event with the given id and dimensions.
/// @param event_id Id of the event to be created.
/// @param num_rows Number of rows of the event to be created.
/// @param num_cols Number of columns of the event to be created.
/// @return 0 if the event was created successfully, 1 otherwise.
int ems_create(unsigned int event_id, size_t num_rows, size_t num_cols);

/// Creates a new reservation for the given event.
/// @param event_id Id of the event to create a reservation for.
/// @param num_seats Number of seats to reserve.
/// @param xs Array of rows of the seats to reserve.
/// @param ys Array of columns of the seats to reserve.
/// @return 0 if the reservation was created successfully, 1 otherwise.
int ems_reserve(unsigned int event_id, size_t num_seats, size_t* xs, size_t* ys);

/// Prints the given event to the given buffer
/// @param event_id Id of the event to print.
/// @param buffer_event_info Pointer to Buffer to store the event informations (rows, cols and every seat in order)
/// @param buffer_event_info_size  A pointer to a variable storing the size of the buffer
/// @return 0 if the event was printed successfully, 1 otherwise.
int ems_show(unsigned int event_id, char** buffer_event_info, size_t* buffer_event_info_size);

/// Prints all the events to the given buffer
/// @param buffer_list_info Pointer to buffer to store the events
/// @param buffer_list_info_size A pointer to a variable storing the size of the buffer
/// @return 0 if the events were printed successfully, 1 otherwise.
int ems_list_events(char** buffer_list_info, size_t* buffer_list_info_size);

/// Called after receiving SIGUSR1, prints to stdout the current full status of the ems
/// @return 0 if all the events and their seats were printed sucessfully
int ems_status();

#endif  // SERVER_OPERATIONS_H
