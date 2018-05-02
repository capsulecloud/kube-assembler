#!/bin/bash

HOST_USER=${HOST_USER:-root}
NODE01=${NODE01:-1.1.1.1}
NODE02=${NODE02:-2.2.2.2}
NODE03=${NODE03:-3.3.3.3}

cat <<EOL
# If you intened to deploy Kubernetes in an air-gapped environment,
# please consult the documentation on how to configure custom RKE images.
nodes:
- address: $NODE01
  port: "22"
  internal_address: ""
  role:
  - controlplane
  - worker
  - etcd
  hostname_override: ""
  user: $HOST_USER
  docker_socket: /var/run/docker.sock
  ssh_key: ""
  ssh_key_path: ~/.ssh/id_rsa
  labels: {}
- address: $NODE02
  port: "22"
  internal_address: ""
  role:
  - controlplane
  - worker
  - etcd
  hostname_override: ""
  user: $HOST_USER
  docker_socket: /var/run/docker.sock
  ssh_key: ""
  ssh_key_path: ~/.ssh/id_rsa
  labels: {}
- address: $NODE03
  port: "22"
  internal_address: ""
  role:
  - controlplane
  - worker
  - etcd
  hostname_override: ""
  user: $HOST_USER
  docker_socket: /var/run/docker.sock
  ssh_key: ""
  ssh_key_path: ~/.ssh/id_rsa
  labels: {}
services:
  etcd:
    image: rancher/coreos-etcd:v3.1.12
    extra_args: {}
    extra_binds: []
    external_urls: []
    ca_cert: ""
    cert: ""
    key: ""
    path: ""
  kube-api:
    image: rancher/hyperkube:v1.10.1-rancher2
    extra_args: {}
    extra_binds: []
    service_cluster_ip_range: 10.43.0.0/16
    pod_security_policy: false
  kube-controller:
    image: rancher/hyperkube:v1.10.1-rancher2
    extra_args: {}
    extra_binds: []
    cluster_cidr: 10.42.0.0/16
    service_cluster_ip_range: 10.43.0.0/16
  scheduler:
    image: rancher/hyperkube:v1.10.1-rancher2
    extra_args: {}
    extra_binds: []
  kubelet:
    image: rancher/hyperkube:v1.10.1-rancher2
    extra_args: {}
    extra_binds: []
    cluster_domain: cluster.local
    infra_container_image: rancher/pause-amd64:3.1
    cluster_dns_server: 10.43.0.10
    fail_swap_on: false
  kubeproxy:
    image: rancher/hyperkube:v1.10.1-rancher2
    extra_args: {}
    extra_binds: []
network:
  plugin: canal
  options: {}
authentication:
  strategy: x509
  options: {}
  sans: []
addons: ""
addons_include: []
system_images:
  etcd: ""
  alpine: ""
  nginx_proxy: ""
  cert_downloader: ""
  kubernetes_services_sidecar: ""
  kubedns: ""
  dnsmasq: ""
  kubedns_sidecar: ""
  kubedns_autoscaler: ""
  kubernetes: ""
  flannel: ""
  flannel_cni: ""
  calico_node: ""
  calico_cni: ""
  calico_controllers: ""
  calico_ctl: ""
  canal_node: ""
  canal_cni: ""
  canal_flannel: ""
  wave_node: ""
  weave_cni: ""
  pod_infra_container: ""
  ingress: ""
  ingress_backend: ""
ssh_key_path: ~/.ssh/id_rsa
ssh_agent_auth: false
authorization:
  mode: rbac
  options: {}
ignore_docker_version: false
kubernetes_version: ""
private_registries: []
ingress:
  provider: ""
  options: {}
  node_selector: {}
  extra_args: {}
cluster_name: ""
cloud_provider:
  name: ""
  cloud_config: {}
prefix_path: ""
EOL