# PLDI2024-CBC

## Getting Started 

We have packaged all the environment and configuration related to the experiment into a docker image and uploaded it to the *DockerHub*. The only thing you need to do is pull it to your local machine.

```
$ docker pull cbc/pldi_2024:v1
$ docker run --rm -ti --ulimit='stack=-1:-1' cbc/pldi_2024:v1
```

## Experiment replay

We designed four experiments to verify the effectiveness of CBC. For the experiment of reproduction, you can go to the ```/home``` directory, and experimental-related tools, as well as benchmarks, are available under the fold.

### To run the whole experiment

```
$ cd /home/benchmark/
$ python3 set.py clean
```

Delete the parameter *`clean`* if you want to keep the intermediate result.

### To run the **Validity** experiment

```
$ cd /home/benchmark/validity
$ python3 init.py clean
```

Delete the parameter *`clean`* if you want to keep the intermediate result.

### To run the **SIR** experiment

```
$ cd /home/benchmark/efficacy
$ python3 init.py clean
```

Delete the parameter *`clean`* if you want to keep the intermediate result.

### To run the **Coreutils** experiment

```
$ cd /home/benchmark/efficiency
$ python3 init.py clean
```

Delete the parameter *`clean`* if you want to keep the intermediate result.

### To run the **CVE** experiment

```
$ cd /home/benchmark/repetition
$ python3 init.py clean
```

Delete the parameter *`clean`* if you want to keep the intermediate result.
