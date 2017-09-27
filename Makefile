.PHONY: all clean test

all:
	jbuilder build --dev

test:
	jbuilder runtest --dev

clean:
	jbuilder clean
