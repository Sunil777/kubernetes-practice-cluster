# K8s Testing Cluster In Seconds

This project helps you create a lightweight local Kubernetes testing cluster inside Docker using `k3s`. It is meant for learning, experimenting, and practicing basic Kubernetes commands without setting up a full cloud cluster.

## What This Project Gives You

- A local single-node Kubernetes cluster using `k3s`
- `kubectl` preconfigured inside the container
- A sample application you can deploy with one command
- A safe playground for learning core Kubernetes concepts

## What Gets Launched

When you start the container and run `./setup.sh`, this project creates:

- One local `k3s` Kubernetes cluster
- One namespace: `k8s-testing`
- One deployment: `echo-app`
- Two pods managed by the deployment
- One service: `echo-service`

## Why This Is Useful

You can use this project to:

- Learn the difference between Pods, Deployments, Services, and Namespaces
- Practice `kubectl` commands in a real cluster
- Test simple YAML manifests
- Understand service discovery and label selectors
- Explore logs, rollout status, scaling, and debugging basics
- Build confidence before moving to larger Kubernetes environments

## Project Files

- `Dockerfile`: builds the learning environment with `k3s` and `kubectl`
- `setup.sh`: creates the namespace, deployment, and service
- `task.yaml`: small metadata file describing the environment
- `README.md`: setup guide and learning notes

## Step 1: Build The Docker Image

```bash
docker build -t k8s-testing-cluster .
```

## Step 2: Run The Container

Run the container in privileged mode so `k3s` can start correctly:

```bash
docker run --privileged -d --name k8s-testing-cluster k8s-testing-cluster
```

## Step 3: Open A Shell Inside The Container

Wait about 15 to 30 seconds for the cluster to boot, then enter the container:

```bash
docker exec -it k8s-testing-cluster bash
```

## Step 4: Check That Kubernetes Is Ready

Use these commands first:

```bash
kubectl get nodes
kubectl cluster-info
kubectl get ns
```

You should see the node in `Ready` state.

## Step 5: Create The Practice Workload

Run:

```bash
./setup.sh
```

This deploys a simple echo application in the `k8s-testing` namespace.

## Basic Kubernetes Commands To Try

These are good starter commands for a learner:

```bash
kubectl get nodes
kubectl get namespaces
kubectl get all -n k8s-testing
kubectl get pods -n k8s-testing
kubectl get svc -n k8s-testing
kubectl get endpoints -n k8s-testing
kubectl describe deployment echo-app -n k8s-testing
kubectl describe service echo-service -n k8s-testing
kubectl logs -n k8s-testing deploy/echo-app
kubectl rollout status deployment/echo-app -n k8s-testing
```

## Example Learning Exercises

Here are some simple things you can practice:

### Scale the application

```bash
kubectl scale deployment echo-app --replicas=3 -n k8s-testing
kubectl get pods -n k8s-testing
```

### Inspect labels

```bash
kubectl get pods -n k8s-testing --show-labels
kubectl get service echo-service -n k8s-testing -o yaml
```

### View full YAML

```bash
kubectl get deployment echo-app -n k8s-testing -o yaml
kubectl get service echo-service -n k8s-testing -o yaml
```

### Test the service from inside the cluster host

```bash
kubectl port-forward service/echo-service 8080:80 -n k8s-testing
```

In another shell inside the container:

```bash
curl http://127.0.0.1:8080
```

You should get:

```text
hello-from-pod
```

## Core Concepts You Can Learn Here

- `Namespace`: a logical boundary for grouping resources
- `Pod`: the smallest runnable unit in Kubernetes
- `Deployment`: manages pod replicas and rollouts
- `Service`: gives stable access to a changing set of pods
- `Labels`: metadata used to group and select resources
- `Selectors`: how Services and Deployments find matching pods

## Reset The Demo Environment

If you run `./setup.sh` again, the namespace is recreated and the sample app is redeployed cleanly.

## Notes

- This is a local testing environment, not a production cluster
- `k3s` is lightweight, so cluster startup is fast
- The sample app is intentionally simple so you can focus on Kubernetes basics
