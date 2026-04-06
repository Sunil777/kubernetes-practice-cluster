# K3s Learning Lab

This project creates a local multi-node Kubernetes cluster using `k3s` and Docker Compose. It is designed as a hands-on learning lab where you can bring up a small Kubernetes environment in minutes, explore how a control-plane works with worker nodes, and practice core `kubectl` workflows on a real cluster.

By default, this lab creates:

- `1` control-plane node
- `2` worker nodes
- `1` sample application namespace
- `1` sample deployment
- `1` sample service

It is a good fit for anyone who wants to learn Kubernetes locally without needing cloud infrastructure.

## What This Project Gives You

- A local multi-node Kubernetes cluster
- One `k3s` server node
- Two `k3s` worker nodes
- `kubectl` ready to use inside the server container
- A sample app you can deploy with one command
- A simple environment for learning scheduling, services, deployments, and cluster basics

## Cluster Architecture

This lab uses a small but realistic Kubernetes layout:

- `k3s-server`: runs the Kubernetes control-plane
- `k3s-worker-1`: joins the cluster as a worker node
- `k3s-worker-2`: joins the cluster as a worker node

The server node is where you run `kubectl`, inspect the cluster, and deploy workloads. The worker nodes are where application pods can be scheduled.

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

This means you get both cluster-level practice and workload-level practice in the same setup.

## Why This Is Useful

You can use this lab to:

- Learn how control-plane and worker nodes work
- Practice `kubectl` commands in a real cluster
- Understand pod scheduling across multiple nodes
- Explore Deployments, Pods, Services, Endpoints, and Namespaces
- Learn labels, selectors, scaling, and service routing
- Test simple manifests before using a bigger environment

This setup is especially useful if you want to understand what happens when pods are distributed across nodes instead of running everything on a single machine.

## Project Files

- `Dockerfile`: base image used for the `k3s` server and worker nodes
- `docker-compose.yml`: starts the multi-node cluster
- `setup.sh`: deploys the sample namespace, deployment, and service
- `task.yaml`: small metadata file describing the lab
- `README.md`: setup guide and learning walkthrough

## What You Can Do With This Lab

With this project, you can:

- Start a multi-node Kubernetes cluster on your local machine
- Learn how nodes join a cluster
- Inspect node roles and pod placement
- Deploy and scale workloads
- Inspect services and endpoints
- Practice debugging with `describe`, `logs`, and `get -o yaml`
- Recreate the environment quickly whenever you want a fresh cluster

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

Expected node layout:

```text
k3s-server
k3s-worker-1
k3s-worker-2
```

## Deploy The Practice Workload

Inside `k3s-server`, run:

```bash
./setup.sh
```

This deploys a simple echo app with `3` replicas so you can observe scheduling across nodes.

After deployment, you can confirm where the pods are running with:

```bash
kubectl get pods -n k8s-testing -o wide
```

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

## Example Learning Flow

If you are new to Kubernetes, a simple learning path with this project is:

1. Start the cluster with Docker Compose.
2. Check that all three nodes are in `Ready` state.
3. Deploy the sample workload using `./setup.sh`.
4. List pods and check which nodes they landed on.
5. Inspect the deployment and service YAML.
6. Scale the deployment and watch Kubernetes create more pods.
7. Use port-forwarding to test service access.
8. Delete and recreate the demo environment to repeat the exercise.

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
