/*
 * A simple libpng example program
 * http://zarb.org/~gc/html/libpng.html
 *
 * Modified by Wonchan Lee to be called from Terra
 *
 * Copyright 2002-2010 Guillaume Cottenceau.
 *
 * This software may be freely redistributed under the terms
 * of the X11 license.
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include "png_util.h"

image_size_t get_image_size(char *filename) {
  image_size_t img_size;
  FILE *fp = fopen(filename, "rb");

  png_structp png =
    png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
  if (!png) abort();

  png_infop info = png_create_info_struct(png);
  if (!info) abort();

  if (setjmp(png_jmpbuf(png))) abort();

  png_init_io(png, fp);

  png_read_info(png, info);

  img_size.width = png_get_image_width(png, info);
  img_size.height = png_get_image_height(png, info);

  fclose(fp);

  return img_size;
}

void read_png_file(char *filename, unsigned char *img, image_size_t img_size) {
  FILE *fp = fopen(filename, "rb");

  png_structp png =
    png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
  if (!png) abort();

  png_infop info = png_create_info_struct(png);
  if (!info) abort();

  if (setjmp(png_jmpbuf(png))) abort();

  png_init_io(png, fp);

  png_read_info(png, info);

  png_byte color_type = png_get_color_type(png, info);
  png_byte bit_depth = png_get_bit_depth(png, info);

  // Supports only gray scale images for now
  if ((color_type == PNG_COLOR_TYPE_GRAY ||
       color_type == PNG_COLOR_TYPE_GRAY_ALPHA) && bit_depth == 8) {
    png_bytepp orig_img =
      (png_bytepp)malloc(sizeof(png_bytep) * img_size.height);
    for (int y = 0; y < img_size.height; y++)
      orig_img[y] = (png_bytep)malloc(png_get_rowbytes(png, info));
    png_read_image(png, orig_img);

    if (color_type == PNG_COLOR_TYPE_GRAY_ALPHA) {
      for (int y = 0; y < img_size.height; y++) {
        for (int x = 0; x < img_size.width; x++) {
          int pixel = orig_img[y][2 * x] + (255 - orig_img[y][2 * x + 1]);
          img[y * img_size.width + x] = pixel > 255 ? 255 : (unsigned int)pixel;
        }
        free(orig_img[y]);
      }
    }
    else {
      for (int y = 0; y < img_size.height; y++) {
        for (int x = 0; x < img_size.width; x++) {
          img[y * img_size.width + x] = orig_img[y][x];
        }
        free(orig_img[y]);
      }
    }
    free(orig_img);
  }

  fclose(fp);
}

void write_png_file(char *filename, unsigned char *img, image_size_t img_size) {
  FILE *fp = fopen(filename, "wb");
  if(!fp) abort();

  png_structp png = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
  if (!png) abort();

  png_infop info = png_create_info_struct(png);
  if (!info) abort();

  if (setjmp(png_jmpbuf(png))) abort();

  png_init_io(png, fp);

  png_set_IHDR(
    png,
    info,
    img_size.width, img_size.height,
    8,
    PNG_COLOR_TYPE_GRAY,
    PNG_INTERLACE_NONE,
    PNG_COMPRESSION_TYPE_DEFAULT,
    PNG_FILTER_TYPE_DEFAULT
  );
  png_write_info(png, info);

  png_bytepp png_img = (png_bytepp)malloc(sizeof(png_bytep) * img_size.height);
  for (int y = 0; y < img_size.height; y++)
    png_img[y] = (png_bytep)malloc(sizeof(png_byte) * img_size.width);
  for (int y = 0; y < img_size.height; y++)
    for (int x = 0; x < img_size.width; x++)
      png_img[y][x] = img[y * img_size.width + x];

  png_write_image(png, png_img);
  png_write_end(png, NULL);

  for (int y = 0; y < img_size.height; y++) free(png_img[y]);
  free(png_img);
  fclose(fp);
}
