
clean:
	if	[ -d ".build" ]; then \
		rm -r .build ; \
	fi

build: clean
	@echo --- Building Nokka
	swift build

test: build
	swift test

build-release clean:
	docker run -v $$(pwd):/tmp/nokka -w /tmp/nokka -it ibmcom/swift-ubuntu:4.0 swift build -c release -Xcc -fblocks -Xlinker -L/usr/local/lib

.PHONY: build test run
