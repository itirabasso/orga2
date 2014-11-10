#ifndef __UTIL_H__
#define __UTIL_H__

#include "defines.h"

int digits(unsigned int n, int base);

unsigned int strlen(const char *s);
void printf(unsigned int col, unsigned int row, const char *format, ...);
void putc(char c, unsigned int col, unsigned int row);
void print_int(unsigned int number, unsigned int col, unsigned int row);
void print_intb(unsigned int n, int base, unsigned int col, unsigned int row);

void print_stacktrace(unsigned int col, unsigned int row);
void print_backtrace(unsigned int col, unsigned int row);

#define GET_REGISTER(register, output) __asm __volatile("movl %%"register", %0;" :"=r"(output));

void* memcpy(void* src, void* dst, int length);
void* memset(void* src, int c, int n);

void handle_keyboard_interrumption(u8 scancode);

#endif  /* !__UTIL_H__ */
