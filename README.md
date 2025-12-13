# Hardware Implementation of Ascon-AEAD128

## Introduction to Ascon

Ascon was selected in 2019 as the winner of the CAESAR competition for lightweight authenticated encryption.
It was specifically designed for use in resource-constrained environments such as embedded systems, where standard AES implementations may be too demanding in terms of area or power consumption [1].

Ascon was developed by Christoph Dobraunig, Maria Eichlseder, Florian Mendel, and Martin Schläffer [2].

In 2024, the National Institute of Standards and Technology (NIST) published an initial public draft for Ascon-based lightweight cryptographic standards [3].

## About This Project

This project implements the **Ascon-AEAD128** algorithm in hardware using **SystemVerilog**.
It was originally developed as part of a school project to learn hardware design and FPGA development. A year later, the project was restarted from scratch, this time based on the official NIST draft specification. Several design and code improvements were made.

Please note that this project is provided **as-is**, without any warranty or guarantee of correctness or suitability for any specific purpose.

Since this was initially a school project, similar Ascon hardware implementations may exist on GitHub.

## Project Structure

- `core/` – All RTL modules that implement Ascon-AEAD128 (excluding system-level interfaces)
- `include/` – Shared package(s) used by both core modules and testbenches
- `testbench/` – Testbenches for all modules in the `core/` directory
- `simu/` *(private)* – Scripts and ModelSim-related files used for simulation

## References

[1] https://csrc.nist.gov/pubs/sp/800/232/ipd

[2] https://ascon.isec.tugraz.at/

[3] Meltem Sönmez Turan, Kerry A. McKay, Donghoon Chang, Jinkeon Kang, John Kelsey (2024) Ascon-Based Lightweight Cryptography Standards for Constrained Devices. (National Institute of Standards and Technology, Gaithersburg, MD),NIST Special Publication (SP) NIST SP 800-232 ipd. https://doi.org/10.6028/NIST.SP.800-232.ipd