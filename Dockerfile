FROM python:3
MAINTAINER "Pietro Bertera" <pietro@bertera.it>

RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive && \
    apt-get update && apt-get -y upgrade && \
    apt-get install -y vim make git pandoc tex-common texlive && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt /
COPY shutil.py.diff /tmp/
RUN pip install -r /requirements.txt
#RUN pip install pelican Markdown ghp-import
#RUN pip install --upgrade pelican Markdown ghp-import

# Workaround shutil see:
# https://github.com/containers/podman/issues/4963
# https://github.com/freeipa/freeipa-container/issues/313
RUN patch /usr/local/lib/python3.8/shutil.py /tmp/shutil.py.diff

WORKDIR /site

RUN mkdir -p /my_themes && cd /my_themes && \
    git clone https://github.com/alexandrevicenzi/Flex.git && cd Flex && \
    git checkout tags/v1.2

RUN pelican-themes --install /my_themes/Flex --verbose && cd /site

ENTRYPOINT ["make"]
