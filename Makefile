.PHONY: all clean test

all:
	dune build

test:
	dune runtest

clean:
	dune clean

docker:
	docker build -t samoht/ramen .
	docker push samoht/ramen
