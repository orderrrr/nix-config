FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install helper and basics, add PPA, then install packages
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl gnupg software-properties-common \
    && add-apt-repository -y ppa:step22/mesa-krunkit \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      mesa-vulkan-drivers \
			vulkan-tools \
    && rm -rf /var/lib/apt/lists/*
