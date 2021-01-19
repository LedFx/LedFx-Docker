# Create docker image from python3.9-slim
FROM python:3.9-slim

# Create python venv and add it to PATH
RUN python -m venv /ledfx/venv \
        && python -m pip install -U pip wheel setuptools
ENV PATH="/ledfx/venv/bin:$PATH"

# Install dependencies and ledfx, remove uneeded packages
#
RUN apt-get update && apt-get install -y --no-install-recommends \
        gcc \
    && apt-get install -y \
        # alsa-utils \
        libatlas3-base \
        portaudio19-dev \
        # pulseaudio \
        python3-dev \
    && pip install ledfx-dev \
    && apt-get purge -y gcc python3-dev \
    && apt-get clean -y \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Add user `ledfx` and create home folder
RUN useradd --create-home ledfx
# Set the working directory in the container
WORKDIR /home/ledfx
USER ledfx

# Expose port 8888 for web server and 5353 for mDNS discovery
EXPOSE 8888/tcp
EXPOSE 5353/udp
ENTRYPOINT [ "ledfx"]
