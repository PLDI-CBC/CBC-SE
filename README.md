# PLDI2024-CBC

## Installing Docker

Follow these links for installation instructions on [Ubuntu](https://docs.docker.com/engine/install/ubuntu/), [OS X](https://docs.docker.com/installation/mac/) and [Windows](https://docs.docker.com/installation/windows/).

## Getting Started 

We have packaged all the environment and configuration related to the experiment into a docker image and uploaded it to the *DockerHub*. The only thing you need to do is pull it to your local machine.

```
$ docker pull cbc/pldi_2024:v1
$ docker run --rm -ti --ulimit='stack=-1:-1' cbc/pldi_2024:v1
```

You can now try running CBC inside the container, by the way our image is based on ubuntu18.04. The version of llvm and clang is 6.0.0. If this worked correctly you should see an output similar to:

```
# clang -v
clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)
Target: x86_64-pc-linux-gnu
Thread model: posix
InstalledDir: /usr/bin
Found candidate GCC installation: /usr/bin/../lib/gcc/x86_64-linux-gnu/7
Found candidate GCC installation: /usr/bin/../lib/gcc/x86_64-linux-gnu/7.5.0
Found candidate GCC installation: /usr/bin/../lib/gcc/x86_64-linux-gnu/8
Found candidate GCC installation: /usr/lib/gcc/x86_64-linux-gnu/7
Found candidate GCC installation: /usr/lib/gcc/x86_64-linux-gnu/7.5.0
Found candidate GCC installation: /usr/lib/gcc/x86_64-linux-gnu/8
Selected GCC installation: /usr/bin/../lib/gcc/x86_64-linux-gnu/7.5.0
Candidate multilib: .;@m64
Selected multilib: .;@m64
```

## Experiment replay

We designed three experiments to verify the effectiveness of CBC. For the experiment of reproduction, you can go to the ```/home``` directory, and experimental-related tools, as well as benchmarks, are available under the fold.

```
# cd /home
# tree -L 1
|-- CBC          // Directory for CBC code
|-- DGSE         // Directory for DGSE code
|-- KLEE         // Directory for KLEE code
|-- benchmarks   // Directory for all experiment files and scripts
|-- dg           // Directory for DG(Static analysis tools)
|-- klee-uclibc  // Directory for KLEE lib
|-- results      // Directory storing experiment results
`-- z3           // Directory for SMT solver
```

The benchmark directory contains all experiments relevant to the work described in this paper.

```
# cd /home/benchmark/
# tree -L 1
|-- CVE             // CVE experiment(Table 2) 
	|-- init.py
|-- Coreutils       // Coreutils experiment(including three small parts)
	|-- Fig5
	|-- Fig6
	|-- Table3
	`-- init.py
|-- SIR             // SIR experiment(Table 1)
	`-- init.py
`-- set.py
```

### To run the whole experiment

If you wish to run the experiment, you can directly execute the following command.

***All experiments will require approximately 540 hours***

```
# python3 set.py clean
```

If you want to keep the intermediate result, delete the parameter *`clean`*, but we recommend keeping the 'clean' option, as the generated intermediate files are large. After execution, the final result will be saved to  CSV files and pictures, so there's no need to worry.

By the way, to save time on reproducing experiments, we have **stored the results from the latest run** in the container as a reference. Also, we highly recommend **parallelizing the implementation** to reduce time overhead, depending on the performance of your setup.

### To run the **SIR** experiment

***This experiment will require approximately 12 hours***

```
# cd /home/benchmark/SIR
# python3 init.py clean
```

### To run the **Coreutils** experiment

```
# cd /home/benchmark/Coreutils
```

#### All Experiments

***These three experiments will require approximately 500 hours***

To run all three experiments, you can directly execute the following command.

```
# python3 init.py clean
```

#### Table3

To get Table 3, you can execute the following command.

***This experiment will require approximately 100 hours***

```
# python3 init.py exe1 clean
```

#### Fig5

To get Fig 5, you can execute the following command.

***This experiment will require approximately 384 hours***

```
# python3 init.py exe2 clean
```

#### Fig6

To get Fig 6, you can execute the following command.

***This experiment will require approximately 24 hours***

```
# python3 init.py exe3 clean
```

Delete the parameter *`clean`* if you want to keep the intermediate result.

### To run the **CVE** experiment

***This experiment will require approximately 24 hours***

```
# cd /home/benchmark/CVE
# python3 init.py clean
```

Delete the parameter *`clean`* if you want to keep the intermediate result.
