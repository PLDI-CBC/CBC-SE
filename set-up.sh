#!/bin/bash

# Get the number of CPU cores
cpu_cores=$(nproc)

# Calculate half of the CPU cores (rounded down to the nearest integer)
half_cpu_cores=$((cpu_cores / 2))

# Function: Execute a command and check its execution result
execute_command() {
    echo "Executing command: $*"
    local half_cpu_cores=$(expr $half_cpu_cores + 0)
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

# Function: Configure, make, and install the project
configure_make_install() {
    local build_dir="$1"
    local make_args="$2"
    shift 2

    local job_count=$(echo "$make_args" | grep -oP '\b\d+\b' || echo "1")

    if [[ $job_count -gt 0 ]]; then
        make_args=$(echo "$make_args" | sed "s/-j $job_count//")
        make_args="-j $job_count $make_args"
    fi

    execute_command cd "$build_dir" || { echo "Failed to change directory to $build_dir"; exit 1; }
    execute_command rm -rf * || { echo "Failed to clean directory"; exit 1; }
    execute_command cmake "$@" || { echo "CMake configuration failed"; exit 1; }
    execute_command make $make_args || { echo "Make failed"; exit 1; }
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

# Move to the CBC-SE directory
cbc_se_dir=$(pwd)  # Replace this with the actual path to your CBC-SE directory
execute_command cd "$cbc_se_dir" || { echo "Failed to change directory to $cbc_se_dir"; exit 1; }

# Unzip all the required files
execute_command unzip -o z3.zip || { echo "Failed to unzip z3.zip"; exit 1; }
execute_command unzip -o KLEE.zip || { echo "Failed to unzip KLEE.zip"; exit 1; }
execute_command unzip -o dg.zip || { echo "Failed to unzip dg.zip"; exit 1; }
execute_command unzip -o DGSE.zip || { echo "Failed to unzip DGSE.zip"; exit 1; }
execute_command unzip -o CBC.zip || { echo "Failed to unzip CBC.zip"; exit 1; }

# Clone klee-uclibc repository if it doesn't exist
if [ ! -d "klee-uclibc" ]; then
    execute_command git clone https://github.com/klee/klee-uclibc.git || { echo "Failed to clone klee-uclibc repository"; exit 1; }
else
    echo "klee-uclibc directory already exists, skipping cloning"
fi


# Move to the klee-uclibc directory
execute_command cd klee-uclibc || { echo "Failed to change directory to klee-uclibc"; exit 1; }

# Configure klee-uclibc and make LLVM library
execute_command ./configure --make-llvm-lib || { echo "Failed to configure klee-uclibc"; exit 1; }
execute_command make -j $half_cpu_cores || { echo "Make failed for klee-uclibc"; exit 1; }

# Configure, make, and install z3
configure_make_install "$cbc_se_dir/z3/build" "-j $half_cpu_cores" -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ .. || { echo "Failed to configure, make, and install z3"; exit 1; }


# Configure, make, and install KLEE
configure_make_install "$cbc_se_dir/KLEE/klee_build" "-j $half_cpu_cores" \
    -DENABLE_SOLVER_Z3=ON \
    -DENABLE_POSIX_RUNTIME=ON \
    -DENABLE_KLEE_UCLIBC=ON \
    -DKLEE_UCLIBC_PATH=$cbc_se_dir/klee-uclibc \
    -DLLVM_CONFIG_BINARY=/usr/bin/llvm-config \
    -DLLVMCC=/usr/bin/clang \
    -DLLVMCXX=/usr/bin/clang++ \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DENABLE_UNIT_TESTS=OFF \
    -DENABLE_SYSTEM_TESTS=OFF \
    -DDG_ROOT_DIR=$cbc_se_dir/dg \
    ../klee/ || { echo "Failed to configure, make, and install KLEE"; exit 1; }

# Configure, make, and install DG
configure_make_install "$cbc_se_dir/dg/build" "-j $half_cpu_cores" -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ .. || { echo "Failed to configure, make, and install DG"; exit 1; }

# Enter DGSE/klee_build directory and make
execute_command cd "$cbc_se_dir/DGSE/klee_build/" || { echo "Failed to change directory to $cbc_se_dir/DGSE/klee_build/"; exit 1; }
configure_make_install "." "-j $half_cpu_cores" \
    -DENABLE_SOLVER_Z3=ON \
    -DENABLE_POSIX_RUNTIME=ON \
    -DENABLE_KLEE_UCLIBC=ON \
    -DKLEE_UCLIBC_PATH=$cbc_se_dir/klee-uclibc \
    -DLLVM_CONFIG_BINARY=/usr/bin/llvm-config \
    -DLLVMCC=/usr/bin/clang \
    -DLLVMCXX=/usr/bin/clang++ \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DENABLE_UNIT_TESTS=OFF \
    -DENABLE_SYSTEM_TESTS=OFF \
    -DDG_ROOT_DIR=$cbc_se_dir/dg \
    ../klee/ || { echo "Failed to configure, make, and install KLEE in $cbc_se_dir/DGSE/klee_build/"; exit 1; }

# Enter CBC/klee_build directory and make
execute_command cd "$cbc_se_dir/CBC/klee_build/" || { echo "Failed to change directory to $cbc_se_dir/CBC/klee_build/"; exit 1; }
configure_make_install "." "-j $half_cpu_cores" \
    -DENABLE_SOLVER_Z3=ON \
    -DENABLE_POSIX_RUNTIME=ON \
    -DENABLE_KLEE_UCLIBC=ON \
    -DKLEE_UCLIBC_PATH=$cbc_se_dir/klee-uclibc \
    -DLLVM_CONFIG_BINARY=/usr/bin/llvm-config \
    -DLLVMCC=/usr/bin/clang \
    -DLLVMCXX=/usr/bin/clang++ \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DENABLE_UNIT_TESTS=OFF \
    -DENABLE_SYSTEM_TESTS=OFF \
    -DDG_ROOT_DIR=$cbc_se_dir/dg \
    ../klee/ || { echo "Failed to configure, make, and install CBC in $cbc_se_dir/CBC/klee_build/"; exit 1; }
