VASM=vasmm68k_mot
VASM_FLAGS=-Ftos -devpac -spaces

ZIP2ST=zip2st

HATARI=hatari
HATARI_FLAGS=--machine st --fast-boot true --fastfdc true

IMAGE_DIR=build

IMAGE = image.st
SOURCES = $(wildcard *.s)
OBJECTS = $(SOURCES:.s=.tos)

all: $(OBJECTS)

%.tos: %.s
	$(VASM) $(VASM_FLAGS) $< -o $@

prepare:
	mkdir -p $(IMAGE_DIR)

$(IMAGE): prepare $(OBJECTS)
	rm -f $(IMAGE)
	rm -f $(IMAGE_DIR)/*
	cp *.tos $(IMAGE_DIR)
	$(ZIP2ST) $(IMAGE_DIR) $(IMAGE)

run: $(IMAGE)
	$(HATARI) $(HATARI_FLAGS) $(IMAGE)

clean:
	rm -Rf $(IMAGE_DIR)
	rm -f $(IMAGE) $(OBJECTS)
