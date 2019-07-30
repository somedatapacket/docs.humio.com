.PHONY: public run

run:
	docker build --target HUGO --tag="humio/docs-local" .
ifdef HUMIO_SRC
	docker run -it --rm -v ${PWD}/content:/var/docs/content -v $(HUMIO_SRC)/target/docs-data/queryfunctions.json:/var/docs/data/functions.json -p 1313:1313 humio/docs-local
else
	docker run -it --rm -v ${PWD}/content:/var/docs/content -p 1313:1313 humio/docs-local
endif

public:
	docker build --tag="humio/docs:latest" .

test: public
	docker rm -f humio-docs || true
	docker run -d --name=humio-docs humio/docs
	mkdir -p test
	docker run --rm --user 1 -v ${PWD}/test:/data --link=humio-docs:humio-docs praqma/linkchecker linkchecker --no-status -ocsv http://humio-docs/ > test/report.csv
	docker rm -f humio-docs
