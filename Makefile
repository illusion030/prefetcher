CC ?= gcc
CFLAGS = -msse2 --std gnu99 -O0 -Wall -Wextra -mavx2

EXEC = naive sse sse_prefetch avx

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

avx: main.c
	$(CC) $(CFLAGS) -DAVX -DNAME=\"avx\" -o avx main.c

run: $(EXEC)
	./naive
	./sse
	./sse_prefetch
	./avx

cache-test: $(EXEC)
	echo 1 | sudo tee /proc/sys/vm/drop_caches
	perf stat --repeat 100 \
	-e cache-misses,cache-references,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,r014c,r024c,r81d0,r01d1,r02d1,r04d1,r08d1,r10d1,r20d1 ./naive
	echo 1 | sudo tee /proc/sys/vm/drop_caches
	perf stat --repeat 100 \
	-e cache-misses,cache-references,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,r014c,r024c,r81d0,r01d1,r02d1,r04d1,r08d1,r10d1,r20d1 ./sse
	echo 1 | sudo tee /proc/sys/vm/drop_caches
	perf stat --repeat 100 \
	-e cache-misses,cache-references,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,r014c,r024c,r81d0,r01d1,r02d1,r04d1,r08d1,r10d1,r20d1 ./sse_prefetch
	echo 1 | sudo tee /proc/sys/vm/drop_caches
	perf stat --repeat 100 \
	-e cache-misses,cache-references,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses,r014c,r024c,r81d0,r01d1,r02d1,r04d1,r08d1,r10d1,r20d1 ./avx

clean:
	$(RM) $(EXEC)
