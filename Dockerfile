# from jessie
FROM debian:8.3

# maintainer info
MAINTAINER Rajiv Kilaparti <kilapartirajiv@gmail.com>

# set env variables
ENV TF_NEED_GCP 0
ENV TF_NEED_CUDA 0
ENV BAZEL_VER 0.2.2
ENV PYTHON_BIN_PATH /usr/bin/python

# install dependencies
RUN echo \
    "deb http://ftp.de.debian.org/debian jessie-backports main" \
    >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -yq \
        --no-install-recommends \
        git \
        tar \
        curl \
        swig \
        xz-utils \
        openjdk-8-jdk \
        build-essential \
        ca-certificates \
        zip unzip zlib1g-dev python \
        python-pip python-dev libpython-dev python-numpy \
    && rm -rf /var/lib/apt/lists/* && update-ca-certificates -f \
    && pip install -U protobuf==3.0.0b2 asciitree && rm -rf /tmp/* && curl -SL \
    "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VER}/bazel-${BAZEL_VER}-installer-linux-x86_64.sh" \
    -o bazel-install.sh && chmod +x bazel-install.sh && ./bazel-install.sh && rm bazel-install.sh

# create directories
RUN mkdir /syntaxnet
WORKDIR /syntaxnet

# git clone and install
RUN git clone --recursive https://github.com/tensorflow/models.git \
    && cd models/syntaxnet/tensorflow && ./configure && cd .. \
    && bazel --batch test --genrule_strategy=standalone --spawn_strategy=standalone syntaxnet/... util/utf8/...

# set the final WORKDIR
WORKDIR /syntaxnet/models/syntaxnet

# entry point command
ENTRYPOINT ["syntaxnet/demo.sh"]
