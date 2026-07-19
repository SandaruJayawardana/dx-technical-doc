.PHONY: all build crm-api crm-manual travelz-api travelz-manual clean

all: build

build:
	./scripts/build.sh all

crm-api:
	./scripts/build.sh document dx-crm api

crm-manual:
	./scripts/build.sh document dx-crm usermanual

travelz-api:
	./scripts/build.sh document dx-travelz api

travelz-manual:
	./scripts/build.sh document dx-travelz usermanual

clean:
	rm -rf dist/*