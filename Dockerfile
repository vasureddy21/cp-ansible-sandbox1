# Use Ubuntu 24.04 (Noble Numbat) as base
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

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

# Install Ansible + dependencies (skip pip upgrade)
RUN pip3 install --break-system-packages --ignore-installed cryptography cffi && \
    pip3 install --break-system-packages "ansible-core>=2.16,<2.17" && \
    pip3 install --break-system-packages mitogen jmespath pywinrm

RUN mkdir -p /etc/ansible /ansible /root/.ssh && \
    echo "Host *" >> /root/.ssh/config && \
    echo "    StrictHostKeyChecking no" >> /root/.ssh/config && \
    ssh-keygen -t rsa -f /root/.ssh/id_rsa -N '' && \
    mkdir -p /ansible/ansible_collections/confluent/platform

ENV ANSIBLE_GATHERING=smart \
    ANSIBLE_HOST_KEY_CHECKING=False \
    ANSIBLE_RETRY_FILES_ENABLED=False \
    ANSIBLE_COLLECTIONS_PATH=/ansible/ansible_collections \
    ANSIBLE_SSH_PIPELINING=True \
    ANSIBLE_HASH_BEHAVIOUR=merge \
    PATH=/ansible/bin:$PATH \
    PYTHONPATH=/ansible/lib \
    ANSIBLE_INVENTORY=/ansible/ansible_collections/confluent/platform/inventories/ansible-inventory.yml

RUN ansible-galaxy collection install ansible.posix community.general

CMD ["sh", "-c", "sleep infinity"]
