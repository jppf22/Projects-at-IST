CC = gcc

# Para mais informações sobre as flags de warning, consulte a informação adicional no lab_ferramentas
CFLAGS = -g -std=c17 -D_POSIX_C_SOURCE=200809L -I. \
		 -Wall -Wextra \
		 -Wcast-align -Wconversion -Wfloat-equal -Wformat=2 -Wnull-dereference -Wshadow -Wsign-conversion -Wswitch-enum -Wundef -Wunreachable-code -Wunused \
		 -pthread
# -fsanitize=address -fsanitize=undefined 

PIPE_NAME = server_pipe

ifneq ($(shell uname -s),Darwin) # if not MacOS
	CFLAGS += -fmax-errors=5
endif

all: server/ems client/client

server/ems: common/pipes.o common/io.o common/constants.h server/main.c server/operations.o server/eventlist.o server/queue.o server/threads.o
	$(CC) $(CFLAGS) $(SLEEP) -o $@ $^

client/client: common/pipes.o common/io.o client/main.c client/api.o client/parser.o
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.c %.h
	$(CC) $(CFLAGS) -c ${@:.o=.c} -o $@

run: server/ems
	@./server/ems $(PIPE_NAME)

clean:
	rm -f common/*.o client/*.o server/*.o server/ems client/client jobs/*.out jobs/*.txt *.txt 

format:
	@which clang-format >/dev/null 2>&1 || echo "Please install clang-format to run this command"
	clang-format -i common/*.c common/*.h client/*.c client/*.h server/*.c server/*.h
