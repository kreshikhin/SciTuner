#include "processing.h"
#include <assert.h>

int main(){
    printf("1. test fft\n");

    double real[4] = {1, 0, 0, 0};
    double imag[4] = {0, 0, 0, 0};

    transform_radix2(real, imag, 4);

    printf("{1, 0, 0, 0} -> %f  %f  %f  %f \n", real[0], real[1], real[2], real[3]);

    assert(real[0] == 1.0);
    assert(real[1] == 1.0);
    assert(real[2] == 1.0);
    assert(real[3] == 1.0);

    printf("2. ceil2 ");

    printf("128, 129, 1000 -> %li  %li  %li\n", ceil2(128.0), ceil2(129.0), ceil2(1000.0));

    assert(ceil2(128.0) == 128);
    assert(ceil2(129.0) == 256);
    assert(ceil2(1000.0) == 1024);

    printf("3. test processing init\n");
    Processing proc;

    processing_init(&proc, 44100.0, 16.0, 32768);

    assert(proc.fd == 44100.0);
    assert(proc.signalLength == 32768);
    assert(proc.bufferLength == 32768 * ceil2(44100.0 / 16.0));

    printf("ok!\n");
}
