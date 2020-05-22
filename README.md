# MIPS CPU

This project helps you set up local development environment on macOS.

## Preparation

```
brew install icarus-verilog verilator
```

Download Scansion app [here](http://www.logicpoet.com/scansion/)

## Usage

Show lint warnings

```bash
make lint
```

Run simulation

```bash
make test_ZeroExt
make test_$(name_of_file_prefix_in_tests_folder)
```

Show simulation result

```bash
make scansion
```

Prepare for git commit

```bash
make clean
```