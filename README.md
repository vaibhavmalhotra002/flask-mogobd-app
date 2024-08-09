# My submission for Flask MongoDB Kubernetes Deployment

## Prerequisites
- Python 3.8+
- Docker
- Kubernetes (Minikube or other local Kubernetes alternatives)

## TASK 1: Local Setup
1. Create and activate a virtual environment
2. Install dependencies
3. Run MongoDB in Docker
4. Set environment variables
5. Run the Flask application

## TASK 2: Kubernetes Setup

## 1. Dockerfile for Flask Application [[dockerfile](https://github.com/vaibhavmalhotra002/flask-mogobd-app/blob/main/dockerfile)]

## 2. Build and push Docker image 

docker build -t flask-mongodb-app .
# Tag and push to a container registry (example using Docker Hub)
docker tag flask-mongodb-app your_dockerhub_username/flask-mongodb-app
docker push your_dockerhub_username/flask-mongodb-app


## 3. Kubernetes Deployment

# Kubernetes YAML files 
[flask-deployment.yaml] 
[mongodb-statefulset.yaml]
[flask-hpa.yaml]

after creating these files we need to deploy them to minikube

## 4. Deploying to Minikube
Start Minikube and apply the YAML files:

minikube start
kubectl apply -f flask-deployment.yaml
kubectl apply -f mongodb-statefulset.yaml
kubectl apply -f flask-hpa.yaml


Deployment and Service for Flask:
1. Apply Flask deployment and service
2. Apply MongoDB StatefulSet and service
3. Apply Horizontal Pod Autoscaler

## Explanation of DNS Resolution in Kubernetes
DNS in Kubernetes: Kubernetes has a built-in DNS server that assigns a DNS name to each service, making inter-pod communication straightforward.
Service Discovery: When the Flask application wants to connect to MongoDB, it uses the DNS name of the MongoDB service (mongodb in this case). Kubernetes resolves this DNS name to the appropriate pod IP address.
## Explanation of Resource Requests and Limits in Kubernetes
Resource Requests: Specify the minimum amount of CPU and memory resources guaranteed to the container.
Resource Limits: Specify the maximum amount of CPU and memory resources the container can use.
Use Case: Ensures that containers have the resources they need to run efficiently, while preventing any single container from monopolizing resources.

### Design Choices and Considerations

#### Flask Application

Configuration:
- Framework: Flask
  - Reason: Flask is a lightweight web framework that's easy to set up and use, making it ideal for simple applications and quick prototyping. It also has a large community and good documentation.
- Database: MongoDB
  - Reason: MongoDB is a NoSQL database that is easy to scale and provides flexibility in data modeling. Its JSON-like documents are a natural fit for the data exchange in web applications.

Alternatives Considered:
- Django: Django is a more heavyweight framework than Flask, providing more built-in features (like an admin panel). However, it can be overkill for simple applications and has a steeper learning curve.
- PostgreSQL/MySQL: These SQL databases offer robust transaction support and relational data management. However, they are more rigid in terms of schema and can be more complex to set up and scale for simple use cases.

#### Docker

Configuration:
- Base Image: `python:3.8-slim`
  - Reason: The slim variant of the Python base image reduces the image size, leading to faster build and deployment times.

Alternatives Considered:
- Alpine Linux: Alpine-based images are even smaller than the slim variants, but they can sometimes have compatibility issues with certain Python packages and libraries.
- Full Python Image: Using the full Python image can simplify the build process since all dependencies are pre-installed, but it results in a significantly larger image size.

#### Kubernetes

Configuration:
- Minikube:
  - Reason: Minikube is a straightforward way to set up a local Kubernetes cluster. It's easy to install and manage, making it ideal for development and testing.

Alternatives Considered:
- Kind: Kind (Kubernetes in Docker) is another tool for running local Kubernetes clusters using Docker. It's lightweight and fast but less commonly used than Minikube.
- MicroK8s: MicroK8s is a lightweight, single-package Kubernetes distribution. It's easy to install and configure, but it can be less intuitive for those familiar with Minikube.

Pod Deployment:
- Flask Deployment: Configured with 2 replicas for high availability and load distribution.
  - Reason: Ensures that the application can handle requests even if one pod fails and allows for load balancing.

- MongoDB StatefulSet: Ensures that MongoDB maintains state across pod restarts and provides persistence.
  - Reason: StatefulSets are designed to manage stateful applications, ensuring consistent network identities and stable storage.

Alternatives Considered:
- Single Pod Deployment: Simplifies the setup but doesn't provide high availability or scalability.
- Deployment for MongoDB: Deployments are typically used for stateless applications, and using them for MongoDB wouldn't ensure data persistence across pod restarts.

Services:
- Service for Flask: NodePort service to expose the application within the cluster and make it accessible from the local machine.
  - Reason: NodePort is simple to set up for local development, allowing access to the application via a specific port on the node.

- Service for MongoDB: ClusterIP service to restrict access within the cluster.
  - Reason: Ensures that the MongoDB service is only accessible by other pods within the cluster, enhancing security.

Alternatives Considered:
- LoadBalancer: Ideal for production environments to manage traffic but not necessary for local development with Minikube.
- ExternalName: Not suitable since we don't need to expose MongoDB to external clients.

Volumes:
- Persistent Volume (PV) and Persistent Volume Claim (PVC): Ensures data persistence for MongoDB.
  - Reason: Provides a mechanism to persist data even if the MongoDB pod is terminated, preventing data loss.

Alternatives Considered:
- EmptyDir: Suitable for temporary data storage but does not provide persistence across pod restarts.

Autoscaling:
- Horizontal Pod Autoscaler (HPA): Configured to scale the Flask application based on CPU usage.
  - Reason: Ensures that the application can handle increased load by automatically scaling up and down based on demand.

Alternatives Considered:
- Manual Scaling: Requires constant monitoring and manual intervention to scale pods, which is inefficient and prone to human error.

Resource Management:
- Resource Requests and Limits: Configured to ensure efficient resource utilization and prevent any single container from monopolizing resources.
  - Reason: Ensures that each pod gets the necessary resources while preventing overuse, leading to a more stable and predictable environment.

Alternatives Considered:
- No Resource Limits: Could lead to resource contention and instability in the cluster, especially under high load conditions.

### Summary of Design Choices

1. Flask + MongoDB: Chosen for simplicity, flexibility, and ease of use.
2. Docker: Slim Python base image for efficient builds and deployments.
3. Kubernetes: Minikube for local development, StatefulSets for MongoDB for state management, Deployments for Flask for high availability, and proper Services for networking.
4. Persistent Volumes: Ensuring data persistence for MongoDB.
5. Horizontal Pod Autoscaler: For automatic scaling based on CPU usage.
6. Resource Requests and Limits: To ensure efficient and stable resource utilization.

### Testing Scenarios

Autoscaling:
- Simulate High Traffic: Use a tool like `ab` (Apache Bench) or `siege` to generate high traffic and observe how the HPA scales the Flask application pods.
  ```sh
  ab -n 1000 -c 100 http://localhost:5000/
  ```
  - Results: Verify that additional pods are created when CPU usage exceeds 70% and are scaled down when the load decreases.

Database Interactions:
- Insert and Retrieve Data: Use `curl` or Postman to send POST and GET requests to the `/data` endpoint and verify data persistence.
  ```sh
  curl -X POST -H "Content-Type: application/json" -d '{"key":"value"}' http://localhost:5000/data
  curl http://localhost:5000/data
  ```
  - Results: Ensure data is correctly inserted and retrieved from MongoDB, even after restarting the MongoDB pod to test data persistence.

