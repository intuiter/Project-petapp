# Application Deployment on Kubernetes using GitOps approach ArgoCD
<p>&nbsp;</p>
Project Presentation Youtube Link: https://youtu.be/j131HImFMV0
<p>&nbsp;</p>
This DevOps lifecycle project focused on a Java-based Spring Boot application called Pet-clinic. The main goal is to use the GitOps tool ArgoCD to automate deployment operations, while integrating various DevOps tools at different stages to streamline tasks and ensure efficient operations.
<p>&nbsp;</p>

## Streamlining the Workflow:

![image](https://github.com/intuiter/Project-petapp/assets/135228471/55ca1daf-8588-464a-92b0-29617949e3a8)

•	The project utilizes GitHub to manage code changes and maintain a single source of truth, ensuring version control.
•	Jenkins served as the workhorse, every time a change is pushed to the Git repository, triggering a build pipeline, automating builds, tests, and deployments.
•	Maven handles building the application, compiling the source code into a deployable .jar file.
•	Sonarqube analyzes the code for potential bugs and vulnerabilities, promoting code quality.
•	JFrog Artifactory acted as a secure repository for storing the generated .jar file.
•	Utilized Docker to package the application into a container image, enabling portability and consistency across environments. Each build is tagged with a unique identifier for version control.
•	Trivy scans the Docker image for security vulnerabilities, ensuring a secure deployment.
•	Dive analyzes the Docker image size and suggests optimizations to minimize resource usage.
•	The final Docker image was pushed to a secure Amazon Elastic Container Registry (ECR) repository.
•	Old, unused Docker images were removed after being pushed to ECR for efficient storage management.
•	Upon a successful CI build, the CD pipeline is triggered, automating deployment. Instead of manual deployments, we employed ArgoCD following the GitOps approach. ArgoCD leverages Git as the single source of truth, managing infrastructure configurations.
•	Deployment manifests residing in a Git repository define the infrastructure configuration for application deployment on Kubernetes. These manifests include service definitions, deployment configurations, database details, and configuration maps.
•	On each code update in Git, the CI/CD pipeline triggered a build. The deployment manifest file was dynamically updated with the latest image tag from ECR.
•	ArgoCD continuously monitors the Git repository for changes. When changes are detected, it automatically synchronizes with the Kubernetes cluster, ensuring the pods running the application reflect the latest updates.
<p>&nbsp;</p>

## Benefits of Automation:
•	Faster Deployments: Automated builds and deployments lead to quicker delivery times.
•	Improved Quality: Static code analysis and vulnerability scanning ensure code quality and security.
•	Reduced Errors: Repeatable and automated processes minimize deployment errors.
•	Increased Efficiency: DevOps tools streamline workflows, freeing up developer time.
<p>&nbsp;</p>

## Demonstration:
•	Created two t2.medium EC2 instances and in one of the machines installed Jenkins, Maven and docker as shown below,
<p>&nbsp;</p>

![image](https://github.com/intuiter/Project-petapp/assets/135228471/e8e21c4c-5e18-4089-8224-a1ec60024bda)

![image](https://github.com/intuiter/Project-petapp/assets/135228471/3c0f8435-9221-4186-946e-1ce9d06d3139)

•	Integrated Jenkins wit Version control Git to get notified and push events post commits.

![image](https://github.com/intuiter/Project-petapp/assets/135228471/4cf1ae4c-53ce-44c7-9f4e-4de1c6ccf056)
<p>&nbsp;</p>
•	On the other EC2 instance created Sonarqube installed, along with docker and Jfrog will run as a container
->>>>> docker run --name artifactory -v /jfrog/artifactory/var:/var/opt/jfrog/artifactory -d -p 8081:8081 -p 8082:8082 docker.bintray.io/jfrog/artifactory-oss:latest
•	The volume mapping in the host machine for which folder we are doing should have the same user id and permission as the folder inside the container. Only then you will have access on the host machine of that volume. For EC2, port 8081 and 8082 should be enabled,
<p>&nbsp;</p>

![image](https://github.com/intuiter/Project-petapp/assets/135228471/7646eeaf-d1a0-43ec-b1dc-8bde88004ddd)
![image](https://github.com/intuiter/Project-petapp/assets/135228471/82e7027e-1bbf-4e0a-bbc8-3b26e68e5427)

•	Below snap shows docker container logs running and successful initialization
<p>&nbsp;</p>

![image](https://github.com/intuiter/Project-petapp/assets/135228471/f3153055-9e34-4234-9269-3b6df73d9c31)

•	Post installation of tools, CI pipeline Job executes the respective stages of tasks for Sonarqube code analysis, Maven compilation generating .jar file consecutively uploading application to Jfrog artifactory repository named “my-jfrog” as below,
<p>&nbsp;</p>

![image](https://github.com/intuiter/Project-petapp/assets/135228471/95e99677-33be-4b9e-91c3-3121f04778af)
![image](https://github.com/intuiter/Project-petapp/assets/135228471/f60fe0de-94d2-45da-b296-8b115a33124b)
![image](https://github.com/intuiter/Project-petapp/assets/135228471/f4666d1b-94df-458a-a364-b813f5177dc1)

•	The JAR file moves to the Docker image build stage. This is built image with a unique build number or image tag. Docker image is then pushed to AWS ECR (Elastic Container Registry). For each version control change, a new image is created and pushed to ECR.
<p>&nbsp;</p>

![image](https://github.com/intuiter/Project-petapp/assets/135228471/35d85312-65a2-4104-8589-0abfd13d9d7f)
![image](https://github.com/intuiter/Project-petapp/assets/135228471/669f377a-522a-4d9b-a8cd-f865fc000b84)

•	ArgoCD detects changes in the Git repository, automatically syncing them with the Kubernetes pods running in the production environment. ArgoCD provides feature to verify App health status and in detailed K8s cluster availability.
<p>&nbsp;</p>

![image](https://github.com/intuiter/Project-petapp/assets/135228471/23d808bf-68fa-4c4d-8e37-885fbcb71e03)

•	Kubectl acts as the user interface (UI) for interacting with a Kubernetes cluster. It allows you to manage and manipulate services, nodes, and pods by creating, configuring, and modifying them.
<p>&nbsp;</p>

![image](https://github.com/intuiter/Project-petapp/assets/135228471/74aa9ffa-edce-4400-851d-079b4881a5f3)

•	Below is the end result of the application, showcasing the application logo and the registration process for pet clinic users, along with the respective specialists who examine the pets. MySQL is configured as the database tier for data storage.
<p>&nbsp;</p>

![image](https://github.com/intuiter/Project-petapp/assets/135228471/bfdef04a-18e1-4e03-a876-9821fc962bdd)

•	To showcase a change in the application feature or code, we updated the application with a new logo and triggered the pipeline. This process dynamically updates the application deployment manifest file with the new image tag, ensuring that the final feature update is automatically reflected as shown below.
<p>&nbsp;</p>

![image](https://github.com/intuiter/Project-petapp/assets/135228471/4c60dbc9-c9fb-41d7-8603-6364887cd178)

•	To monitor the health and performance of Kubernetes clusters, Prometheus is installed and integrated to collect metrics from nodes and services. These metrics and logs are then visualized through user-friendly dashboards in Grafana. Together, Prometheus and Grafana act as a powerful monitoring suite, enabling analysis and troubleshooting of application and optimization issues. 
<p>&nbsp;</p>

![image](https://github.com/intuiter/Project-petapp/assets/135228471/8a7cc17d-6868-4a89-be72-74a88d6cbe3e)
<p>&nbsp;</p>

![image](https://github.com/intuiter/Project-petapp/assets/135228471/41cf4a56-41e9-4b34-adc0-4ea573d9eef6)




















