########## CONFIGURATION ##########



##### General #####

# Do not edit this
DEFAULT_PROJECT_NAME := defaultprojectname

# Edit this, replacing $(DEFAULT_PROJECT_NAME) with your project name
PROJECT_NAME := $(DEFAULT_PROJECT_NAME)

PATH := ./node_modules/.bin:$(PATH)
ENVIRONMENT ?= development
SUDO ?= $(PROJECT_NAME)
RSYNC_CMD = rsync -avc --delete --exclude '.htaccess' --recursive --chmod=F640,D750 $(OUTPUT_DIR)/ $(INSTALL_DIR)/



##### Directories #####


# Input directories

INPUT_DIR := src
CSS_INPUT_DIR = $(INPUT_DIR)/scss
FONT_INPUT_DIR = $(INPUT_DIR)/fonts
HTML_INPUT_DIR = $(INPUT_DIR)/html
IMG_INPUT_DIR = $(INPUT_DIR)/img
JS_INPUT_DIR = $(INPUT_DIR)/js/node_modules
JS_APP_INPUT_DIR = $(JS_INPUT_DIR)/app
JS_LIBRARY_INPUT_DIR = $(JS_INPUT_DIR)/lib


# Output directories

OUTPUT_DIR := dist
CSS_OUTPUT_DIR = $(OUTPUT_DIR)/css
FONT_OUTPUT_DIR = $(OUTPUT_DIR)/fonts
HTML_OUTPUT_DIR = $(OUTPUT_DIR)
IMG_OUTPUT_DIR = $(OUTPUT_DIR)/img
JS_OUTPUT_DIR = $(OUTPUT_DIR)/js


# Installation directories

INSTALL_DIR ?= /path/to/website/public


# Misc directories

NODE_MODULES_DIR := node_modules
TESTS_DIR := tests



##### Entry points #####

CSS_ENTRY_POINT = $(CSS_INPUT_DIR)/index.scss
JS_ENTRY_POINT = $(JS_APP_INPUT_DIR)/app/index.js



##### Input-output mapping #####


# CSS

CSS_INPUTS = $(filter-out $(CSS_ENTRY_POINT), $(wildcard $(CSS_INPUT_DIR)/*.scss))
CSS_OUTPUTS = $(CSS_OUTPUT_DIR)/bundle.css


# HTML

HTML_INPUTS = $(shell find $(HTML_INPUT_DIR) -type f -name '*.html')
HTML_OUTPUTS = $(patsubst $(HTML_INPUT_DIR)/%,$(HTML_OUTPUT_DIR)/%,$(HTML_INPUTS))


# Fonts

FONT_INPUTS = $(wildcard $(FONT_INPUT_DIR)/*.eot $(FONT_INPUT_DIR)/*.woff $(FONT_INPUT_DIR)/*.woff2 $(FONT_INPUT_DIR)/*.ttf $(FONT_INPUT_DIR)/*.otf $(FONT_INPUT_DIR)/*.svg)
FONT_OUTPUTS = $(patsubst $(FONT_INPUT_DIR)/%,$(FONT_OUTPUT_DIR)/%,$(FONT_INPUTS))


# Images

IMG_INPUTS = $(wildcard $(IMG_INPUT_DIR)/*.png $(IMG_INPUT_DIR)/*.gif $(IMG_INPUT_DIR)/*.jpg $(IMG_INPUT_DIR)/*.jpeg $(IMG_INPUT_DIR)/*.svg $(IMG_INPUT_DIR)/*.bmp $(IMG_INPUT_DIR)/*.webp $(IMG_INPUT_DIR)/*.ico)
IMG_OUTPUTS = $(patsubst $(IMG_INPUT_DIR)/%,$(IMG_OUTPUT_DIR)/%,$(IMG_INPUTS))


# Javascript

JS_LIBRARY_INPUTS = $(wildcard $(JS_LIBRARY_INPUT_DIR)/*/index.js)
JS_APP_INPUTS = $(filter-out $(JS_ENTRY_POINT), $(wildcard $(JS_APP_INPUT_DIR)/*/index.js) $(JS_LIBRARY_INPUTS))
JS_OUTPUTS = $(JS_OUTPUT_DIR)/bundle.js



##### Assemble outputs #####

OUTPUTS = $(NODE_MODULES_DIR) $(JS_OUTPUTS) $(CSS_OUTPUTS) $(IMG_OUTPUTS) $(FONT_OUTPUTS) $(HTML_OUTPUTS)



##### Helper functions #####

COMPILE_MSG = @printf "Compiling $^\n--> $@\n\n"



##### Compilation commands #####

ifeq ($(ENVIRONMENT),development)
define BROWSERIFY_CMD =
@browserify --debug $< > $@
endef
SASS_CMD = @sass $< | postcss -u autoprefixer > $@
else ifeq ($(ENVIRONMENT),staging)
BROWSERIFY_CMD = @browserify -g uglifyify $< | terser -c warnings=false -o $@
SASS_CMD = @sass $< | postcss -u autoprefixer cssnano | cleancss -o $@
else ifeq ($(ENVIRONMENT),production)
BROWSERIFY_CMD = @browserify -g uglifyify $< | terser -c warnings=false -o $@
SASS_CMD = @sass $< | postcss -u autoprefixer cssnano | cleancss -o $@
else
$(error Unrecognised ENVIRONMENT $(ENVIRONMENT))
endif





########## RULES ##########


# Top level

.PHONY: all install clean init test

install: all
	@mkdir -p $(INSTALL_DIR)
	@if [ -z $(SUDO) ]; then $(RSYNC_CMD); else sudo -u $(SUDO) $(RSYNC_CMD); fi

clean:
	@printf "Deleting directories: $(OUTPUT_DIR)\n\n"
	@rm -rf $(OUTPUT_DIR)

all: $(OUTPUTS)
	@echo > /dev/null

init:
	@if [ -z $(ENVIRONMENT) ]; then printf "Error: Missing value for ENVIRONMENT\n"; exit 1; fi
	@if [ $(ENVIRONMENT) != 'development' ]; then printf "Error: project initialisation can only be run in a development environment. Actual environment: $(ENVIRONMENT)\n"; exit 1; fi
	@printf "Updating the project name\n\n"
	@grep -rl $(DEFAULT_PROJECT_NAME) --exclude-dir=.git --exclude=Makefile | xargs -r sed -i 's/$(DEFAULT_PROJECT_NAME)/$(PROJECT_NAME)/g'

test: $(NODE_MODULES_DIR)
	@mocha


# CSS

$(CSS_OUTPUT_DIR)/bundle.css: $(CSS_ENTRY_POINT) $(CSS_INPUTS)
	$(COMPILE_MSG)
	@mkdir -p $(@D)
	$(SASS_CMD)


# HTML

$(HTML_OUTPUT_DIR)/%.html: $(HTML_INPUT_DIR)/%.html
	$(COMPILE_MSG)
	@mkdir -p $(@D)
	@cp $< $@


# Fonts

$(FONT_OUTPUT_DIR)/% : $(FONT_INPUT_DIR)/%
	$(COMPILE_MSG)
	@mkdir -p $(@D)
	@cp $< $@


# Images - BMP

$(IMG_OUTPUT_DIR)/%.bmp : $(IMG_INPUT_DIR)/%.bmp
	$(COMPILE_MSG)
	@mkdir -p $(@D)
	@cp $< $@


# Images - GIF

$(IMG_OUTPUT_DIR)/%.gif : $(IMG_INPUT_DIR)/%.gif
	$(COMPILE_MSG)
	@mkdir -p $(@D)
	@cp $< $@


# Images - ICO

$(IMG_OUTPUT_DIR)/%.ico : $(IMG_INPUT_DIR)/%.ico
	$(COMPILE_MSG)
	@mkdir -p $(@D)
	@cp $< $@


# Images - JPG

$(IMG_OUTPUT_DIR)/%.jpg : $(IMG_INPUT_DIR)/%.jpg
	$(COMPILE_MSG)
	@mkdir -p $(@D)
	@TARGET=`basename $@ .jpg`;imagemin $< --plugin=mozjpeg > $(@D)/"$$TARGET".min.jpg
	@TARGET=`basename $@ .jpg`;cwebp $< -q 90 -o $(@D)/"$$TARGET".webp
	@cp $< $@


# Images - JPEG

$(IMG_OUTPUT_DIR)/%.jpeg : $(IMG_INPUT_DIR)/%.jpeg
	$(COMPILE_MSG)
	@mkdir -p $(@D)
	@TARGET=`basename $@ .jpeg`;imagemin $< --plugin=mozjpeg > $(@D)/"$$TARGET".min.jpeg
	@TARGET=`basename $@ .jpeg`;cwebp $< -q 90 -o $(@D)/"$$TARGET".webp
	@cp $< $@


# Images - PNG

$(IMG_OUTPUT_DIR)/%.png : $(IMG_INPUT_DIR)/%.png
	$(COMPILE_MSG)
	@mkdir -p $(@D)
	@TARGET=`basename $@ .png`;imagemin $< --plugin=pngquant > $(@D)/"$$TARGET".min.png
	@TARGET=`basename $@ .png`;cwebp $< -q 90 -o $(@D)/"$$TARGET".webp
	@cp $< $@


# Images - SVG

$(IMG_OUTPUT_DIR)/%.svg : $(IMG_INPUT_DIR)/%.svg
	$(COMPILE_MSG)
	@mkdir -p $(@D)
	@TARGET=`basename $@ .svg`;svgo $< -o $(@D)/"$$TARGET".min.svg
	@cp $< $@


# Images - WEBP

$(IMG_OUTPUT_DIR)/%.webp : $(IMG_INPUT_DIR)/%.webp
	$(COMPILE_MSG)
	@mkdir -p $(@D)
	@cp $< $@


# Javascript

$(JS_OUTPUT_DIR)/bundle.js: $(JS_ENTRY_POINT) $(JS_APP_INPUTS)
	$(COMPILE_MSG)
	@mkdir -p $(@D)
	$(BROWSERIFY_CMD)


# Node modules

$(NODE_MODULES_DIR): package.json
	npm install
