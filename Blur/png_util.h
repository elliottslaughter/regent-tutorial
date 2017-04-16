#ifndef __PNG_UTIL__
#define __PNG_UTIL__

#include <png.h>

typedef struct image_size_t {
  int width;
  int height;
} image_size_t;

image_size_t get_image_size(char*);

void read_png_file(char*, unsigned char*, image_size_t);

void write_png_file(char*, unsigned char*, image_size_t);

#endif
