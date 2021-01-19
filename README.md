# ledfx-docker

An attempt at running LedFX inside a docker container

## How these files work

### **Dockerfile:**

This file uses the python:3.7-slim image:

* It first creates a python virtual environment /ledfx/venv
* "activate" the python venv by adding it to the `PATH`
* Install compile and run dependencies with `apt-get`
* Install ledfx-dev from `pip`
* Purge compile dependencies with `apt-get`, `clean` and `autoremove`
* Add ledfx user and create a home folder
* Set `WORKDIR` to ledfx home directory and change `USER` to ledfx
* `EXPOSE` ports 8888 and 5353
* Launch ledfx

How to use: `docker build -t ledfx .`

### **Dockerfile-2stage-1:**

This file uses the python:3.7-slim image:

1. Create a "compile-image"

   * Set `WORKDIR` to /ledfx
   * Install compile dependencies with `apt-get`
   * Clone ledfx dev branch into /ledfx using `git clone`
   * cd to /ledfx/frontend
   * Install `yarn` and build the frontend
   * cd to /ledfx
   * Create a python venv /ledfx/venv and "activate" it by adding it to the `PATH`
   * Install ledfx-dev from source using `pip`

2. Create a "build-image"

   * `COPY` /ledfx/venv from "compile-image" to current image
   * Activate the venv by adding it to the `PATH`
   * Install run dependencies with `apt-get`
   * Add ledfx user and create a home folder
   * Set `WORKDIR` to ledfx home directory and change `USER` to ledfx
   * `EXPOSE` ports 8888 and 5353
   * Launch ledfx

How to use: `docker build -t ledfx-2stage -f Dockerfile-2stage-1 .`

### **Dockerfile-4stage:**

This file uses docker's multi-stage build technique to speed up the build process using the cache and cut down the overall size of the final image.

While all 4 images will be built initially, we can significantly cut down the build times by using the cached images that won't change regularly. Docker will use the cache up until the point in the Dockerfile that it detects a change. Any lines after that change will be build from scratch.

By creating the venv and compile images in the beggining of the Dockerfile, we can be fairly certain that these dependencies won't change regularly. This cuts down the time required to build by skipping the dependency installation process.

1. Create "venv-image"

   * Create a python venv /ledfx/venv and "activate" it by adding it to the `PATH`
   * Install compile and run dependencies with `apt-get`

2. Create "compile-image" from "venv-image"

   * Install build dependencies with `apt-get`

3. Create "build-image" from "compile-image"

   * `COPY` /ledfx/venv from "venv-image" to current image
   * Activate the venv by adding it to the `PATH`
   * Set `WORKDIR` to /ledfx-git
   * Clone ledfx dev branch into /ledfx-git using `git clone`
   * `cd` to /ledfx/frontend
   * Install `yarn` and build the frontend
   * `cd` to /ledfx
   * Create a python venv /ledfx/venv and "activate" it by adding it to the `PATH`
   * Install ledfx-dev from source using `pip`

4. Create "dist-image" from "venv-image"

   * `COPY` /ledfx/venv from "build-image" to current image
   * Activate the venv by adding it to the `PATH`
   * Remove all lists from /var/lib/apt/lists/
   * Add ledfx user and create a home folder
   * Set `WORKDIR` to ledfx home directory and change `USER` to ledfx
   * `EXPOSE` ports 8888 and 5353
   * Launch ledfx

How to use: `docker build -t ledfx-4stage -f Dockerfile-4stage .`

### **Dockerfile.venv, Dockerfile.compile, Dockerfile.build:**

These files take a similar approach to Dockerfile-4stage. They differ in the fact that they use 3 independent Dockerfile's to achieve the same results. I'm not sure if this is significant, but I was learning how to create Dockerfile's when I wrote these so I decided to try it out.

1. Dockerfile.venv

   * Create "venv-image" from python:3.7-slim
   * Create a python venv /ledfx/venv and "activate" it by adding it to the `PATH`
   * Install run dependencies with `apt-get`

How to use: `docker build -t thatdonfc/ledfx-venv -f Dockerfile.venv .`

2. Dockerfile.compile

   * Create "compile-image" from "venv-image" named thatdonfc/ledfx-venv
   * Activate the venv by adding it to the `PATH`
   * Install build dependencies with `apt-get`
   * Install ledfx-dev with `pip`

How to use: `docker build -t thatdonfc/ledfx-compile -f Dockerfile.compile .`

3. Dockerfile.build

   * Create build image from "venv-image" named thatdonfc/ledfx-venv
   * `COPY` /ledfx/venv from "compile-image" named thatdonfc/ledfx-compile
   * Remove all lists from /var/lib/apt/lists/
   * Add ledfx user and create a home folder
   * Set `WORKDIR` to ledfx home directory and change `USER` to ledfx
   * `EXPOSE` ports 8888 and 5353
   * Launch ledfx

How to use: `docker build -t thatdonfc/ledfx-build -f Dockerfile.build .`
