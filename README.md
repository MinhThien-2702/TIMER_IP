# Timer IP Module

The Timer IP module is a crucial component designed for precise timing operations in a chip environment. It provides essential functionalities that can be utilized in various applications, including pulse generation, delay generation, event generation, PWM generation, and interrupt generation.

## Overview

This project customizes a timer module based on the CLINT (Core Local Interruptor) module of the industrial RISC-V architecture. It is designed to generate interrupts based on user settings and includes various features to enhance its usability.

### Key Features

- **64-bit Count-Up**: The timer counts upwards, providing a wide range of count values for various timing needs.
- **Address Space**: The timer occupies a 4KB address space ranging from `0x4000_1000` to `0x4000_1FFF`.
- **Register Set Configured via APB Bus**: The timer's control registers are accessible through the APB (Advanced Peripheral Bus), allowing for efficient configuration and control.
  - **Registers Include**:
    - **Mode Registers**: Configurable for different counting modes (e.g., default mode and control mode).
    - **Interrupt Control Registers**: Enable or disable interrupts based on user settings.
- **Support for Wait States**: The timer can accommodate wait states, requiring only one cycle for operations.
- **Byte Access Support**: The timer supports access to individual bytes within its registers.
- **Debug Mode Halt Support**: The timer can halt operations during debug mode to facilitate easier debugging.
- **System Clock Frequency**: Operates at a system clock frequency of 200 MHz, ensuring precise timing operations.
- **Active Low Asynchronous Reset**: The timer supports an active low asynchronous reset for reliable operation.
- **Counter Division**: The counter can count based on the system clock or be divided down to a maximum of 256.
- **Interrupt Generation**: Supports timer interrupts that can be enabled or disabled as per user requirements.

## GitHub Repository Structure

The project is organized into several directories to facilitate development and testing:

- **`rtl/`**: Contains the RTL (Register Transfer Level) code for the Timer IP module, including the implementation of the timer, APB slave interface, and related components.
- **`tb/`**: Contains testbench files for simulating the Timer IP module and verifying its functionality through simulation tools.
- **`testcases/`**: Contains specific test cases designed to validate various functionalities and features of the Timer IP module, ensuring compliance with the specified requirements.

### Usage

The Timer IP module can be integrated into larger systems requiring precise timing functionalities. To configure the timer and utilize its features, users can interact with the APB slave interface, accessing the various registers for mode selection, interrupt control, and counter configuration.

### References

For detailed specifications of the CLINT module, please refer to the [CLINT Documentation](https://chromitem-soc.readthedocs.io/en/latest/clint.html).
