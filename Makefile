CC ?= gcc
CFLAGS = -msse2 --std gnu99 -O0 -Wall -Wextra

EXEC = naive sse sse_prefetch

GIT_HOOKS := .git/hooks/applied

all: $(GIT_HOOKS) $(EXEC)

$(GIT_HOOKS):
	@scripts/install-git-hooks
	@echo

naive: main.c
	$(CC) $(CFLAGS) -DNAIVE -DNAME=\"naive\" -o naive main.c

sse: main.c
	$(CC) $(CFLAGS) -DSSE -DNAME=\"sse\" -o sse main.c

sse_prefetch: main.c
	$(CC) $(CFLAGS) -DSSE_PREFETCH -DNAME=\"sse_prefetch\" -o sse_prefetch main.c

run: $(EXEC)
	./naive
	./sse
	./sse_prefetch

cache-test: $(EXEC)
	sudo perf stat --repeat 100 \
	-e cache-misses,cache-references,L1-dcache-load-misses,L1-icache-load-misses,r14c,r24c ./naive
	sudo perf stat --repeat 100 \
	-e cache-misses,cache-references,L1-dcache-load-misses,L1-icache-load-misses,r14c,r24c ./sse
	sudo perf stat --repeat 100 \
	-e cache-misses,cache-references,L1-dcache-load-misses,L1-icache-load-misses,r14c,r24c ./sse_prefetch

clean:
	$(RM) $(EXEC)
