CC ?= gcc
CFLAGS = -msse2 --std gnu99 -O0 -Wall -Wextra

EXEC = naive sse sse_prefetch

GIT_HOOKS := .git/hooks/applied

all: $(GIT_HOOKS) $(EXEC)

$(GIT_HOOKS):
	@scripts/install-git-hooks
	@echo

naive: main.c
	$(CC) $(CFLAGS) -D NAIVE -o naive main.c

sse: main.c
	$(CC) $(CFLAGS) -D SSE -o sse main.c

sse_prefetch: main.c
	$(CC) $(CFLAGS) -D SSE_PREFETCH -o sse_prefetch main.c

run: $(EXEC)
	./naive
	./sse
	./sse_prefetch

cache-test: $(EXEC)
	sudo perf stat --repeat 100 \
	-e cache-misses,cache-references,L1-dcache-load-misses,L1-icache-load-misses ./naive
	sudo perf stat --repeat 100 \
	-e cache-misses,cache-references,L1-dcache-load-misses,L1-icache-load-misses ./sse
	sudo perf stat --repeat 100 \
	-e cache-misses,cache-references,L1-dcache-load-misses,L1-icache-load-misses ./sse_prefetch

clean:
	$(RM) $(EXEC)
