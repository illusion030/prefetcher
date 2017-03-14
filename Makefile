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
	perf stat --repeat 100 \
	-e cache-misses,cache-references,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,r014c,r024c,r81d0,r01d1,r02d1,r04d1,r08d1,r10d1,r20d1 ./naive
	perf stat --repeat 100 \
	-e cache-misses,cache-references,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,r014c,r024c,r81d0,r01d1,r02d1,r04d1,r08d1,r10d1,r20d1 ./sse
	perf stat --repeat 100 \
	-e cache-misses,cache-references,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,r014c,r024c,r81d0,r01d1,r02d1,r04d1,r08d1,r10d1,r20d1 ./sse_prefetch

clean:
	$(RM) $(EXEC)
