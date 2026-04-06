FROM python:3.11-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends bash curl ca-certificates iproute2 iptables procps && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fL "https://github.com/k3s-io/k3s/releases/download/v1.29.6%2Bk3s2/k3s" -o /usr/local/bin/k3s && \
    chmod +x /usr/local/bin/k3s && \
    ln -s /usr/local/bin/k3s /usr/local/bin/kubectl

WORKDIR /workspace

COPY setup.sh task.yaml README.md /workspace/

RUN chmod +x /workspace/setup.sh
ENV KUBECONFIG=/etc/rancher/k3s/k3s.yaml

CMD ["k3s", "server", "--write-kubeconfig-mode", "644", "--disable", "traefik", "--disable", "servicelb", "--snapshotter", "native"]
