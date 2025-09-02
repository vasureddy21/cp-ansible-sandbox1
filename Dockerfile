# Use Ubuntu 24.04 (Noble Numbat) as base
FROM ubuntu:24.04

# Prevent APT from asking interactive questions
ARG DEBIAN_FRONTEND=noninteractive

# Install required system packages
RUN apt-get update && apt-get install -y \
        sudo \
        python3 \
        python3-pip \
        python3-dev \
        openssl \
        ca-certificates \
        sshpass \
        openssh-client \
        rsync \
        git \
        gcc \
        libffi-dev \
        libssl-dev \
        make \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip & install Ansible (latest 2.16.x) + Python tooling
RUN pip3 install --upgrade pip wheel && \
    pip3 install --upgrade cryptography cffi && \
    pip3 install "ansible-core>=2.16,<2.17" && \
    pip3 install mitogen jmespath pywinrm

# Create Ansible directories
RUN mkdir -p /etc/ansible /ansible /root/.ssh

# Disable SSH host key checking
RUN echo "Host *" >> /root/.ssh/config && \
    echo "    StrictHostKeyChecking no" >> /root/.ssh/config

# Generate SSH key for container
RUN ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ''

# Create playbook directory
RUN mkdir -p /ansible/ansible_collections/confluent/platform

# Environment variables for Ansible
ENV ANSIBLE_GATHERING=smart \
    ANSIBLE_HOST_KEY_CHECKING=False \
    ANSIBLE_RETRY_FILES_ENABLED=False \
    ANSIBLE_COLLECTIONS_PATH=/ansible/ansible_collections \
    ANSIBLE_SSH_PIPELINING=True \
    ANSIBLE_HASH_BEHAVIOUR=merge \
    PATH=/ansible/bin:$PATH \
    PYTHONPATH=/ansible/lib \
    ANSIBLE_INVENTORY=/ansible/ansible_collections/confluent/platform/inventories/ansible-inventory.yml

# Install useful Ansible community collections
RUN ansible-galaxy collection install ansible.posix community.general

# Keep container running
CMD ["sh", "-c", "sleep infinity"]
