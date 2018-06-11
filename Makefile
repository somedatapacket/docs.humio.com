clean:
	rm -rf public test data/releases.yml

data/releases.yml:
	curl -s https://repo.humio.com/repository/maven-releases/com/humio/server/1.0.68/server-1.0.68.releases.json > data/releases.yml

public: data/releases.yml
	hugo
	docker build --tag="humio/docs:latest" .

test: public
	docker rm -f humio-docs || true
	docker run -d --name=humio-docs humio/docs
	mkdir -p test
	docker run --rm --user 1 -v ${PWD}/test:/data --link=humio-docs:humio-docs praqma/linkchecker linkchecker --no-status -ocsv http://humio-docs/ > test/report.csv
	docker rm -f humio-docs
