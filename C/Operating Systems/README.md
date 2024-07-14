# Operating Systems Final Project

This project simulates a university scheduler and reservation system for seats and rooms.
For simulating different user sessions, it relies on multi-threaded paradigms.

## Usage

- Compiling: `make`
- Cleaning: `make clean`
- Running: On different terminals do:
    - Starting the server: `./session/ems {server_pipe name}`
    - Start a client session: `./client/client {requests_pipe} {responses_pipe} {server_pipe} {path to .jobs file}`

## Testing
- The script *tester.sh* can be run using `sh tester.sh` after ensuring it is executable through `chmod +x tester.sh`
- It will run all `.jobs` files in the jobs folder, in the background, at the same time, displaying the system capacity to handle more clients than the `MAX_SESSION_COUNT` (set to 8, by default).
- Each `{client_name}.job` will have a `${client_name}_log.txt`, with its stderr.
- The server stdout goes into `server_output.txt` and stderr into `server_log.txt`

**Note:** The provided tests (ex.jobs) conflict with each other on purpose to simulate multiple clients interacting over same events
## Calling SIGUSR1
- On a different terminal (or on the same one if the clients and server and run on the background):
    - Getting PID of the server: `pgrep ems` or `ps`
    - Sending SIGUSR1: `kill -SIGUSR1 {pid}` where `{pid}` is replaced by the PID of the server

## Terminating the server
- Not implemented (use `kill {pid}`, where {pid} is the PID of the server)


