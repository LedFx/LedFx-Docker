# Create docker image from python3.9-slim
FROM python:3.9-slim

# Create python venv and add it to PATH
RUN python -m venv /ledfx/venv \
        && python -m pip install -U pip wheel setuptools
ENV PATH="/ledfx/venv/bin:$PATH"

# Install dependencies and ledfx, remove uneeded packages
#
RUN apt-get update 
RUN apt-get install -y --no-install-recommends \
        gcc \
        # alsa-utils \
        libatlas3-base \
        portaudio19-dev \
        # pulseaudio \
        python3-dev 
RUN pip install ledfx-dev
RUN apt-get purge -y gcc python3-dev 
RUN apt-get clean -y 
RUN apt-get autoremove -y 
RUN rm -rf /var/lib/apt/lists/*

# Add user `ledfx` and create home folder
RUN useradd --create-home ledfx
# Set the working directory in the container
WORKDIR /home/ledfx
USER ledfx

# Expose port 8888 for web server and 5353 for mDNS discovery
EXPOSE 8888/tcp
EXPOSE 5353/udp
ENTRYPOINT [ "ledfx"]
