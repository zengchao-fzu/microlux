#ifndef AR0130_H
#define AR0130_H

#include <stdint.h>

struct ar0130_exposure_config {
    uint16_t x_start;
    uint16_t x_end;
    uint16_t y_start;
    uint16_t y_end;

    uint8_t gain;
    uint8_t offset;

    uint16_t duration_coarse;
    uint16_t duration_fine;
    uint16_t line_width;
};

void ar0130_init(void);
void ar0130_start_exposure(struct ar0130_exposure_config *new_config);
void ar0130_stop_exposure(void);

#endif
