#!/bin/bash

PART_LIST="./parts-list.txt"

# if no arg,
if [ $# -ne 1 ]; then
  echo "Usage: ./generate_project_from_evt.sh <part>" 
  echo "please specify a ch5xx ble part:"
  while IFS= read -r line
  do
    part=$(echo "$line"|awk -F ' ' '{print $1}'| tr '[:upper:]' '[:lower:]')
    echo "$part"
  done < "$PART_LIST"
  exit
fi

# iterate the part list to found part info.
PART=$(echo "$1" | tr '[:upper:]' '[:lower:]')
FLASHSIZE=
RAMSIZE=
STARTUP_ASM=
ZIPFILE=

FOUND="f"

while IFS= read -r line
do
  cur_part=$(echo "$line"|awk -F ' ' '{print $1}'| tr '[:upper:]' '[:lower:]')
  FLASHSIZE=$(echo "$line"|awk -F ' ' '{print $2}')
  RAMSIZE=$(echo "$line"|awk -F ' ' '{print $3}')
  STARTUP_ASM=$(echo "$line"|awk -F ' ' '{print $4}')
  ZIPFILE=$(echo "$line"|awk -F ' ' '{print $5}')
  if [ "$cur_part""x" == "$PART""x" ]; then
    FOUND="t"
    break;
  fi
done < "$PART_LIST"

#if not found
if [ "$FOUND""x" == "f""x" ];then
  echo "Your part is not supported."
  exit
fi

# found
echo "Convert project for $PART"
echo "part : $PART"
echo "flash size : $FLASHSIZE"
echo "ram size : $RAMSIZE"
echo "#########################"

# clean
rm -rf evt_tmp
# remove all sources, copy from EVT later
# do not remove User dir.
rm -rf CH5xx_firmware_library Examples

echo "Extract EVT package"
mkdir -p evt_tmp
unzip -q -O gb18030 $ZIPFILE -d evt_tmp

# prepare dir structure
mkdir -p CH5xx_firmware_library
cp -r evt_tmp/EVT/EXAM/SRC/* CH5xx_firmware_library/

# prepare examples
mkdir -p Examples
cp -r evt_tmp/EVT/EXAM/* Examples
rm -rf Examples/SRC

# drop evt
rm -rf evt_tmp

echo "Process linker script"
LD_TEMPLATE=
if [[ $PART = ch571 ]]; then
  LD_TEMPLATE=Link.ch573.ld.template
elif [[ $PART = ch573 ]]; then
  LD_TEMPLATE=Link.ch573.ld.template
elif [[ $PART = ch581 ]]; then
  LD_TEMPLATE=Link.ch583.ld.template
elif [[ $PART = ch582 ]]; then
  LD_TEMPLATE=Link.ch583.ld.template
elif [[ $PART = ch583 ]]; then
  LD_TEMPLATE=Link.ch583.ld.template
elif [[ $PART = ch584 ]]; then
  LD_TEMPLATE=Link.ch585.ld.template
elif [[ $PART = ch585 ]]; then
  LD_TEMPLATE=Link.ch585.ld.template
elif [[ $PART = ch591 ]]; then
  LD_TEMPLATE=Link.ch592.ld.template
elif [[ $PART = ch592 ]]; then
  LD_TEMPLATE=Link.ch592.ld.template
else
  echo "Part $part is not supported"
  exit
fi

# generate the Linker script
sed "s/FLASH_SIZE/$FLASHSIZE/g" $LD_TEMPLATE > CH5xx_firmware_library/Ld/Link.ld
sed -i "s/RAM_SIZE/$RAMSIZE/g" CH5xx_firmware_library/Ld/Link.ld

echo "Generate Makefile"
# collect c files and asm files
find . -path ./Examples -prune -o -type f -name "*.c"|sed 's@^\./@@g;s@$@ \\@g' > c_source.list
# drop Examples line in source list.
sed -i "/^Examples/d" c_source.list

sed "s/C_SOURCE_LIST/$(sed -e 's/[\&/]/\\&/g' -e 's/$/\\n/' c_source.list | tr -d '\n')/" Makefile.ch5xx.template >Makefile
sed -i "s/STARTUP_ASM_SOURCE_LIST/CH5xx_firmware_library\/Startup\/$STARTUP_ASM/" Makefile

rm -f c_source.list

sed -i "s/CH5XX/$PART/g" Makefile

if [[ $PART = ch571 ]]; then
  sed -i "s/^#include \"CH5.*/#include \"CH57x_common.h\"/g" User/Main.c
  sed -i "s/libISP5xx.a/libISP573.a/g" Makefile 
fi

if [[ $PART = ch573 ]]; then
  sed -i "s/^#include \"CH5.*/#include \"CH57x_common.h\"/g" User/Main.c
  sed -i "s/libISP5xx.a/libISP573.a/g" Makefile 
fi

if [[ $PART = ch581 ]]; then
  sed -i "s/^#include \"CH5.*/#include \"CH58x_common.h\"/g" User/Main.c
  sed -i "s/libISP5xx.a/libISP583.a/g" Makefile 
fi

if [[ $PART = ch582 ]]; then
  sed -i "s/^#include \"CH5.*/#include \"CH58x_common.h\"/g" User/Main.c
  sed -i "s/libISP5xx.a/libISP583.a/g" Makefile
fi

if [[ $PART = ch583 ]]; then
  sed -i "s/^#include \"CH5.*/#include \"CH58x_common.h\"/g" User/Main.c
  sed -i "s/libISP5xx.a/libISP583.a/g" Makefile
fi

if [[ $PART = ch584 ]]; then
  sed -i "s/^#include \"CH5.*/#include \"CH58x_common.h\"/g" User/Main.c
  sed -i 's@SetSysClock(CLK_SOURCE_PLL_60MHz);@HSECFG_Capacitance(HSECap_18p);\n    SetSysClock(CLK_SOURCE_HSE_PLL_62_4MHz);@g' User/Main.c
  sed -i "s/libISP5xx.a/libISP585.a/g" Makefile
fi

if [[ $PART = ch585 ]]; then
  sed -i "s/^#include \"CH5.*/#include \"CH58x_common.h\"/g" User/Main.c
  sed -i 's@SetSysClock(CLK_SOURCE_PLL_60MHz);@HSECFG_Capacitance(HSECap_18p);\n    SetSysClock(CLK_SOURCE_HSE_PLL_62_4MHz);@g' User/Main.c
  sed -i "s/libISP5xx.a/libISP585.a/g" Makefile
fi

if [[ $PART = ch591 ]]; then
  sed -i "s/^#include \"CH5.*/#include \"CH59x_common.h\"/g" User/Main.c
  sed -i "s/libISP5xx.a/libISP592.a/g" Makefile
fi

if [[ $PART = ch592 ]]; then
  sed -i "s/^#include \"CH5.*/#include \"CH59x_common.h\"/g" User/Main.c
  sed -i "s/libISP5xx.a/libISP592.a/g" Makefile
fi


echo "#########################"
echo "Done, project generated, type 'make' to build"
