# K3s Learning Lab

This project creates a local multi-node Kubernetes lab using `k3s` and Docker Compose. It is designed for learning Kubernetes basics on a cluster that includes one control-plane node and two worker nodes.

## What This Project Gives You

- A local multi-node Kubernetes cluster
- One `k3s` server node
- Two `k3s` worker nodes
- `kubectl` ready to use inside the server container
- A sample app you can deploy with one command
- A simple environment for learning scheduling, services, deployments, and cluster basics

## What Gets Launched

When you start the lab, this project brings up:

- `k3s-server`: the control-plane node
- `k3s-worker-1`: a worker node
- `k3s-worker-2`: a worker node
- A Docker bridge network for the cluster containers

When you run `./setup.sh` inside the server container, it also creates:

- Namespace: `k8s-testing`
- Deployment: `echo-app`
- Replicas: `3`
- Service: `echo-service`

## Why This Is Useful

You can use this lab to:

- Learn how control-plane and worker nodes work
- Practice `kubectl` commands in a real cluster
- Understand pod scheduling across multiple nodes
- Explore Deployments, Pods, Services, Endpoints, and Namespaces
- Learn labels, selectors, scaling, and service routing
- Test simple manifests before using a bigger environment

## Project Files

- `Dockerfile`: base image used for the `k3s` server and worker nodes
- `docker-compose.yml`: starts the multi-node cluster
- `setup.sh`: deploys the sample namespace, deployment, and service
- `task.yaml`: small metadata file describing the lab
- `README.md`: setup guide and learning walkthrough

## Start The Multi-Node Cluster

Build and start the cluster:

```bash
docker compose up -d --build
```

If your system uses the older Compose CLI:

```bash
docker-compose up -d --build
```

## Open A Shell In The Server Node

Wait about 20 to 40 seconds, then enter the control-plane container:

```bash
docker exec -it k3s-server bash
```

This is the main container where you will run `kubectl`.

## Check Cluster Status

Inside the `k3s-server` container, run:

```bash
kubectl get nodes
kubectl get nodes -o wide
kubectl cluster-info
kubectl get namespaces
```

You should see `3` nodes in `Ready` state.

## Deploy The Practice Workload

Inside `k3s-server`, run:

```bash
./setup.sh
```

This deploys a simple echo app with `3` replicas so you can observe scheduling across nodes.

## Basic Commands To Learn Kubernetes

These are great starter commands:

```bash
kubectl get nodes
kubectl get pods -A -o wide
kubectl get all -n k8s-testing
kubectl get pods -n k8s-testing -o wide
kubectl get svc -n k8s-testing
kubectl get endpoints -n k8s-testing
kubectl describe node k3s-server
kubectl describe node k3s-worker-1
kubectl describe deployment echo-app -n k8s-testing
kubectl describe service echo-service -n k8s-testing
kubectl logs -n k8s-testing deployment/echo-app
kubectl rollout status deployment/echo-app -n k8s-testing
```

## Example Commands To Practice

### See where pods are running

```bash
kubectl get pods -n k8s-testing -o wide
```

### Scale the deployment

```bash
kubectl scale deployment echo-app --replicas=5 -n k8s-testing
kubectl get pods -n k8s-testing -o wide
```

### Inspect labels and selectors

```bash
kubectl get pods -n k8s-testing --show-labels
kubectl get service echo-service -n k8s-testing -o yaml
kubectl get deployment echo-app -n k8s-testing -o yaml
```

### Watch pods in real time

```bash
kubectl get pods -n k8s-testing -w
```

### Test service access

```bash
kubectl port-forward service/echo-service 8080:80 -n k8s-testing
```

In another shell inside `k3s-server`:

```bash
curl http://127.0.0.1:8080
```

Expected response:

```text
hello-from-pod
```

### Explore cluster-wide resources

```bash
kubectl get all -A
kubectl top nodes
kubectl top pods -A
```

Note: `kubectl top` works only if metrics are available in the cluster.

## Concepts You Can Learn Here

- `Control Plane`: manages the cluster and handles API requests
- `Worker Node`: runs application workloads
- `Namespace`: groups resources logically
- `Pod`: the smallest deployable unit in Kubernetes
- `Deployment`: manages replica count and pod rollout
- `Service`: gives stable network access to pods
- `Labels`: key-value metadata attached to objects
- `Selectors`: rules used to match objects by label
- `Scheduling`: how Kubernetes chooses which node runs a pod

## Reset The Demo App

Run `./setup.sh` again to recreate the demo namespace and workload from scratch.

## Stop The Cluster

From your project directory on the host machine:

```bash
docker compose down
```

To remove containers, network, and related state more cleanly:

```bash
docker compose down -v
```

## Troubleshooting

If worker nodes do not join and logs mention `overlayfs snapshotter cannot be enabled`, restart the cluster after rebuilding:

```bash
docker compose down -v
docker compose up -d --build
```

This project is configured to use the `native` snapshotter because `overlayfs` may fail in some Docker environments.

If you see a `resolv.conf includes loopback or multicast nameservers` warning, that is usually non-fatal and does not stop the cluster from working.

## Notes

- This is a learning lab for local use, not a production cluster
- `k3s` is lightweight, so it is a good fit for local multi-node experiments
- The sample deployment uses multiple replicas so you can practice node-level inspection
