FROM registry.fedoraproject.org/fedora:44

RUN dnf -y install \
        crypto-policies-scripts \
        flatpak \
        flatpak-builder \
        git \
        jq \
        ostree \
        wget \
        xz \
    && dnf clean all

COPY NO-MLKEM.pmod /etc/crypto-policies/policies/modules/NO-MLKEM.pmod

RUN update-crypto-policies --set DEFAULT:NO-MLKEM

ENV LANG=C.UTF-8
WORKDIR /workspace
