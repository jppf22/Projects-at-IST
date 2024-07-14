#!/bin/bash

# Start the server command and redirect the error output to a log file
./server/ems teste > server_output.txt 2> server_log.txt &

# Iterate over each file in the jobs folder and run client command for each program
for job_file in jobs/*.jobs; do
  if [ -f "$job_file" ]; then
    program_name=$(basename "$job_file" .jobs)
    ./client/client "${program_name}_req" "${program_name}_resp" "teste" "$job_file" 2> "jobs/${program_name}_log.txt" &
  fi
done


