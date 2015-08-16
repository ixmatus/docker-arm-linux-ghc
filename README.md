#docker-arm-linux-ghc

This package contains a Dockerfile and associated scripts to build a GHC 7.8.4 cross compiler targeting the
ARM architecture. Big thanks go out *neuroctye* for the original build script, *sseefried*
(https://github.com/sseefried/docker-build-ghc-android) for the original Android docker file and recipes,
and *joeyh* for additional changes.

You will see some errors in the standard output, some that even look like they might be fatal.
Stay strong and wait. It will build to the end. If it doesn't please contact me.

## Platform notes
This is different from the Android build. *Your target must have the same glibc version of your
cross-compiler toolchain*. Note that the docker container this dockerfile imports is specific to our needs
at Plum. If you need something different, you should produce your own cross compiler toolchain docker
container, push it, reference it as an import, and change the necessary environment variables in
*set-env.sh*.

I've done my best to keep it as general as possible.

## libgmp
If you're changing the ARM platform you're targeting than the one in here, you should probably generate a
new gmp constants header. I will describe how to do this in an update soon.

# Installation

*Please build with at least Docker version 1.6*. Check with `docker version`.

Once you've done that then:

    $ docker build .

# Running

You'll want to run the image inside an interactive shell. At the end of
the build it will tell you the image ID of the final image.

$ docker run -it <image ID> bash

# Motivation

This build script takes between 1 - 2 hours to run. It installs several
packages, some that require patches to make them work with Android.
Developing a build script with this many dependencies is a nightmare.

You can only be sure your script *really* works if you run it on a pristine
environment. But when your script breaks after 50 minutes it is just the sort of
thing that can make you want to consider changing careers, especially if it
happens a few times in a row. Development is made so much easier with
quick turn-around times.

The fantastic thing about Docker is that it effectively takes a snapshot of the *entire
file system* after each Dockerfile command allowing you to return to that
known state and try again.

Docker is great because:

1. It helped *me*. This script was developed much more quickly than it otherwise
   would have been. Because of how Docker works I had the confidence that it
   would build from a pristine environment once I had successfully built it the
   first time.


2. It will help *you*. This script will inevitably succumb to bitrot.
   It may fail but when it does you will not have to go all the way back to the
   beginning. You can make a change to one of the many mini-scripts in the
   ```user-scripts/``` directory and try again from the point of failure.

## More information

For more information read my [blog post](http://lambdalog.seanseefried.com/posts/2014-12-12-docker-build-scripts.html).
