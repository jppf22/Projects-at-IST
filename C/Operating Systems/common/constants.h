#define MAX_RESERVATION_SIZE 256
#define STATE_ACCESS_DELAY_US 500000  // 500ms
#define MAX_JOB_FILE_NAME_SIZE 256
#define MAX_SESSION_COUNT 8  // The number of worker threads (change for better or worse performance)

#define REGISTER_BUFSIZE (size_t)81  // the sizeof the client registration buffer

// As you can see below, each command has an associated OP_CODE
#define SETUP_CODE 1
#define QUIT_CODE 2
#define CREATE_CODE 3
#define RESERVE_CODE 4
#define SHOW_CODE 5
#define LIST_CODE 6