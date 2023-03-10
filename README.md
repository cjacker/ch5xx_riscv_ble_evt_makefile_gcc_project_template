# WCH CH5xx RISC-V BLE EVT with GCC and Makefile support

This is a project template with related tools to convert WCH official CH5xx RISC-V BLE EVT package to a GCC and Makefile project.

This template will convert the EVT package to a Makefile project and setup Link.ld according to your MCU, it support All CH5xx RISC-V BLE EVT packages from WCH, include:

- CH573EVT.ZIP
  + CH571
  + CH573
- CH583EVT.ZIP
  + CH581
  + CH582
  + CH583

## Usage

Assume you already have 'riscv-none-embed-gcc' toolchain installed. to generate a gcc/makefile project for specific part, type:
```
./generate_project_from_evt.sh <part>
```
If you want to change to another part in same family after project generated, use `./setpart.sh <part>`.

If you do not know which part you should specify, please run `./generate_project_from_evt.sh` without arg directly for help.

After project generated, there is a 'User' dir contains the codes you should write or modify. By default, it is a GPIO_Toggle can be used to blink LED.

Then type `make` to build the project.

The `<part>.elf` / `<part>.bin` / `<part>.hex` will be generated at 'build' dir and can be programmed to target device later.

