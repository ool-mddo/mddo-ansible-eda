FROM quay.io/ansible/ansible-rulebook:v1.3.2
ARG USER_ID=1001
#ARG USER_ID=${USER_ID:-1001}
ARG STATIC_ROOT=/var/lib/eda/static
USER 0

ARG PYTHON_BIN="python3.12"
RUN dnf upgrade -y "${PYTHON_BIN}" && \
    ln -sf "/usr/bin/${PYTHON_BIN}" /usr/bin/python3 && \
    ln -sf "/usr/bin/${PYTHON_BIN}" /usr/bin/python

RUN pip install --no-cache-dir --root-user-action=ignore -U \
    pip \
    ansible-core \
    ansible-rulebook \
    paramiko \
    jmespath \
    netaddr \
    pynetbox \
    ttp \
    ansible-pylibssh \
    xmltodict

RUN ansible-galaxy collection install -U \
    ansible.eda \
    ansible.netcommon \
    ansible.utils \
    netbox.netbox \
    junipernetworks.junos \
    cisco.iosxr \
    arista.eos \
    community.general

# jq & docker-ce install
RUN curl -fsSL https://download.docker.com/linux/centos/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo && \
    sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/docker-ce.repo && \
    dnf --enablerepo=docker-ce-stable -y install jq docker-ce && \
    dnf clean all

ENV POETRY_VERSION="1.8.3" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    POETRY_NO_INTERACTION=1 \
    VIRTUAL_ENV=/app/venv \
    SOURCES_DIR=/app/src \
    PATH="/app/.local/bin:$PATH" \
    HOME="/app"
CMD ["aap-eda-manage", "runserver", "0.0.0.0:8000"]
