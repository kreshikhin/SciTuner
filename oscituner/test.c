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

    printf("ok!\n");
}
