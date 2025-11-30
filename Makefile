# MkDocs commands
.PHONY: install docs serve build deploy

install:
	pip install -r requirements.txt

docs: install
	mkdocs build

serve: install
	mkdocs serve

build: install
	mkdocs build -d site

deploy: install
	mkdocs gh-deploy