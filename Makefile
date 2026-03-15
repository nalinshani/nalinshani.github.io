# All Jemdoc files
DOCS=index

## HTML Files
HDOCS=$(addsuffix .html, $(DOCS))
PHDOCS=$(addprefix html/, $(HDOCS))

.PHONY : all
all : $(PHDOCS)
	rm -f html/*.jemdoc
	cp -f -r ./jemdoc/images ./html
	cp -f -r ./jemdoc/documents ./html
	cp -f -r ./eqs ./html | true
	sed -i 's/<head>/<head>\n<meta name="viewport" content="width=device-width, initial-scale=1.0" \/>/' html/index.html
	sed -i 's/<\/title>/<\/title>\n<meta name="description" content="Personal website and academic portfolio of Nalin Shani, focusing on online review systems, consumer behavior, and platform operations.">/' html/index.html
	sed -i 's/<head>/<head>\n<meta name="google-site-verification" content="fqiyIsNLJgQebtFdA2DG63fb4hCXNo3s3coM7YSotF0" \/>/' html/index.html
	@echo "Website building is complete !"

html/%.html : jemdoc/%.jemdoc jemdoc/jemdoc.css
	$(eval HTML_FILE_PATH := $@)
	$(eval JEMDOC_FILE_PATH := $<)
	$(eval HTML_DIR := $(shell dirname $(HTML_FILE_PATH)))
	$(eval JEMDOC_DIR := $(shell dirname $(JEMDOC_FILE_PATH)))
	$(eval HTML_FILE_NAME := $(shell basename $(HTML_FILE_PATH)))
	$(eval JEMDOC_FILE_NAME := $(shell basename $(JEMDOC_FILE_PATH)))
	mkdir -p $(HTML_DIR)
	cp $(JEMDOC_DIR)/*.* $(HTML_DIR)
	rm -f $(HTML_DIR)/$(JEMDOC_FILE_NAME)
	./jemdoc.py -c website.conf -o $@ $<

.PHONY : clean
clean :
	rm -f -r html/
	rm -f -r eqs/

.PHONY : install
install :
	curl https://jemdoc.jaboc.net/dist/jemdoc.py > ./jemdoc.py
	chmod +x ./jemdoc.py

.PHONY : pull
pull :
	git pull

.PHONY : push
push :
	git add .
	git commit -m"Some modifications"
	git push
	
.PHONY : publishall
publishall :
	$(eval ftp_site := mywebsite.com)
	$(eval FTP_MIRROR_PATH := html)
	$(eval USERNAME ?= $(shell read -p "FTP Username: " pwd; echo $$pwd))
	$(eval PASSWORD ?= $(shell read -p "FTP Password: " pwd; echo $$pwd))
	$(MAKE) pull
	lftp -e "set ftp:ssl-allow no; set xfer:clobber on; get /rss/news.rss; exit" -u $(USERNAME),$(PASSWORD) $(ftp_site)
	cp news.rss ./news_bkp/$(shell date --iso=seconds).rss	
	mv news.rss ./html/rss/
	$(MAKE) push -i
	$(MAKE) all	
	lftp -e "set ftp:ssl-allow no; mirror -Rne ./$(FTP_MIRROR_PATH) /; exit" -u $(USERNAME),$(PASSWORD) $(ftp_site)
	
	