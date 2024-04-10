#!/bin/bash

# Function: Execute a command and check its execution result
execute_command() {
    echo "Executing command: $*"
    "$@" || { echo "Command execution failed: $*"; exit 1; }
}

# Function: Install a package using apt-get
install_package() {
    execute_command apt-get install -y "$@" || { echo "Package installation failed: $*"; exit 1; }
}

# Function: Install a Python package using pip
install_python_package() {
    execute_command pip3 install "$@" || { echo "Python package installation failed: $*"; exit 1; }
}

# Function: Configure and make the project
configure_and_make() {
    local build_dir="$1"
    local make_args="$2"
    shift 2
    execute_command cd "$build_dir" || { echo "Failed to change directory to $build_dir"; exit 1; }
    execute_command rm -rf * || { echo "Failed to clean directory"; exit 1; }
    execute_command cmake "$@" || { echo "CMake configuration failed"; exit 1; }
    execute_command make "$make_args" || { echo "Make failed"; exit 1; }
    execute_command make install || { echo "Make install failed"; exit 1; }
}

# Update package list
execute_command apt update || { echo "Package list update failed"; exit 1; }

# Install essential build tools
install_package build-essential python-minimal python-pip libncurses-dev zlib1g-dev llvm clang cmake python3 curl doxygen libcap-dev sqlite3 libsqlite3-dev python3-pip unzip

# Upgrade pip
execute_command pip3 install --upgrade pip || { echo "Failed to upgrade pip"; exit 1; }

# Install Python libraries
install_python_package sklearn xlwings matplotlib pillow pandas tabulate

# Install Google performance tools library
install_package libgoogle-perftools-dev

# Move to the /home directory
execute_command cd /home/ || { echo "Failed to change directory to /home"; exit 1; }

# Unzip z3.zip
execute_command unzip z3.zip || { echo "Failed to unzip z3.zip"; exit 1; }

# Unzip KLEE.zip
execute_command unzip KLEE.zip || { echo "Failed to unzip KLEE.zip"; exit 1; }

# Unzip DG.zip
execute_command unzip dg.zip || { echo "Failed to unzip dg.zip"; exit 1; }

# Unzip DGSE.zip
execute_command unzip DGSE.zip || { echo "Failed to unzip DGSE.zip"; exit 1; }

# Unzip CBC.zip
execute_command unzip CBC.zip || { echo "Failed to unzip CBC.zip"; exit 1; }

# Unzip benchmarks.zip
execute_command unzip benchmarks.zip || { echo "Failed to unzip benchmarks.zip"; exit 1; }

# Unzip results.zip
execute_command unzip results.zip || { echo "Failed to unzip results.zip"; exit 1; }

# Clone klee-uclibc repository
execute_command git clone https://github.com/klee/klee-uclibc.git || { echo "Failed to clone klee-uclibc repository"; exit 1; }

# Move to the klee-uclibc directory
execute_command cd klee-uclibc || { echo "Failed to change directory to klee-uclibc"; exit 1; }

# Configure klee-uclibc and make LLVM library
execute_command ./configure --make-llvm-lib || { echo "Failed to configure klee-uclibc"; exit 1; }
execute_command make -j2 || { echo "Make failed for klee-uclibc"; exit 1; }

# Get the number of CPU cores and calculate half of them
cpu_cores=$(nproc)
half_cpu_cores=$((cpu_cores / 2))

# Configure and make z3
configure_and_make "z3/build" "-j $half_cpu_cores" -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ .. || { echo "Failed to configure and make z3"; exit 1; }

# Configure and make KLEE
configure_and_make "KLEE/klee_build" "-j $half_cpu_cores" \
    -DENABLE_SOLVER_Z3=ON \
    -DENABLE_POSIX_RUNTIME=ON \
    -DENABLE_KLEE_UCLIBC=ON \
    -DKLEE_UCLIBC_PATH=/home/klee-uclibc \
    -DLLVM_CONFIG_BINARY=/usr/bin/llvm-config \
    -DLLVMCC=/usr/bin/clang \
    -DLLVMCXX=/usr/bin/clang++ \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DENABLE_UNIT_TESTS=OFF \
    -DENABLE_SYSTEM_TESTS=OFF \
    -DDG_ROOT_DIR=/home/dg \
    ../klee/ || { echo "Failed to configure and make KLEE"; exit 1; }

# Configure and make dg
configure_and_make "DG/build" "-j $half_cpu_cores" -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ .. || { echo "Failed to configure and make DG"; exit 1; }

# Enter DGSE/klee_build directory and make
execute_command cd /home/DGSE/klee_build/ || { echo "Failed to change directory to /home/DGSE/klee_build/"; exit 1; }
configure_and_make "." "-j $half_cpu_cores" \
    -DENABLE_SOLVER_Z3=ON \
    -DENABLE_POSIX_RUNTIME=ON \
    -DENABLE_KLEE_UCLIBC=ON \
    -DKLEE_UCLIBC_PATH=/home/klee-uclibc \
    -DLLVM_CONFIG_BINARY=/usr/bin/llvm-config \
    -DLLVMCC=/usr/bin/clang \
    -DLLVMCXX=/usr/bin/clang++ \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DENABLE_UNIT_TESTS=OFF \
    -DENABLE_SYSTEM_TESTS=OFF \
    -DDG_ROOT_DIR=/home/dg \
    ../klee/ || { echo "Failed to configure and make KLEE in /home/DGSE/klee_build/"; exit 1; }

# Enter CBC/klee_build directory and make
execute_command cd /home/CBC/klee_build/ || { echo "Failed to change directory to /home/CBC/klee_build/"; exit 1; }
configure_and_make "." "-j $half_cpu_cores" \
    -DENABLE_SOLVER_Z3=ON \
    -DENABLE_POSIX_RUNTIME=ON \
    -DENABLE_KLEE_UCLIBC=ON \
    -DKLEE_UCLIBC_PATH=/home/klee-uclibc \
    -DLLVM_CONFIG_BINARY=/usr/bin/llvm-config \
    -DLLVMCC=/usr/bin/clang \
    -DLLVMCXX=/usr/bin/clang++ \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DENABLE_UNIT_TESTS=OFF \
    -DENABLE_SYSTEM_TESTS=OFF \
    -DDG_ROOT_DIR=/home/dg \
    ../klee/ || { echo "Failed to configure and make CBC in /home/CBC/klee_build/"; exit 1; }
