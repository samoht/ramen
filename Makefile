.PHONY: all clean test

all:
	jbuilder build --dev

test:
	jbuilder runtest --dev

clean:
	jbuilder clean

docker:
	docker build -t samoht/ramen .
	docker push samoht/ramen
