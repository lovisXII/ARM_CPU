# Introduction

This project is the material decription of an ARMv2a architecture. It s describe using VHDL langage. Every file have been created by Louis Geoffroy Pitailler and Timothée Le Berre, excepting the file inside C_model which have been created by our teacher Jean-Lou Debardieux.\
We developped this architecture during our first Master year at Sorbonne University.

# File architecture :

* C_model : Contains a library allowing to parse and elf file. It also contains the source of an armv2a simulator. Everything in this directory have been developped by Jean-Lou Debardieux
* CHIP : contains the VHDL description of our chip
* Compte_rendu : Contain a pdf for our final project report
* CORE : Contains the VHDL description of our implementation
* synth : contain files we used for the synthesis of our ship using alliance tools
* TB : contain the executable resulting of our main test bench  and some tests
* TOOLS : contains binary for arm compiler
* work  : contain object files

# What's needed

To compile this project you will need :
* ghdl (you need to recompile ghdl llvm using gcc), please update your path in the makefile in TOOLS/Makefile
* gcc
* make
* The binary of the armv2a compiler are for a Linux-Ubuntu distribution, if you're using a different distribution you will need to use other binary
* You will need to setup the alliance toolchain from the Lip6 if you want to realise the synthesis of the chip (The makefile give you the possibility to do the synthesis)

Here's a small script to recompile ghdl-llvm :
```sh
#! /bin/bash
apt install gnat
apt install clang
apt install llvm
echo "Installing dependencies"
apt-get install libedit clang lldb lld pkg-config zlib1g-dev gnat

echo "Downloading ghdl sources"
wget https://github.com/ghdl/ghdl/archive/master.tar.gz
tar -xvf master.tar.gz
cd ghdl-master && mkdir -p build 
cd build && ../configure --with-llvm-config=/usr/bin/llvm-config --prefix=/opt/ghdl
make 
make install 

echo "export ghdl=/opt/ghdl/bin/ghdl" >> ~/.bashrc
source ~/.bashrc
```

# How to compile

Once you have all the needed tools please do the following commands from the root:
```bash
cd TB
make
```
Then you have to choose a .s or .c file, for example :\
``tests/test_acces_mem_multiple.s``\
Then you need to use the proper compiler, in our case :
```bash
arm-linux-gnu-as tests/test_acces_mem_multiple.s
```
It will generate a file named ``a.out``.\
You juste have to give it as parameter to the executable main_tb :
```bash
./main_tb a.out 
```
If the test works you will have ``good`` printed on your terminal, otherwise it will print ``bad``
