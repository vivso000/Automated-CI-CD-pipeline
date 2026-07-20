# Step-by-Step Execution Guide & Technical Interview Guide

> **Project Jugaad:** Zero-Touch Automated DevOps Pipeline for Java Spring Boot on AWS Free Tier.

---

## 📋 Table of Contents
1. [Step 1: Local Java & Maven Build Verification](#step-1-local-java--maven-build-verification)
2. [Step 2: Multi-Stage Docker Container Verification](#step-2-multi-stage-docker-container-verification)
3. [Step 3: Provisioning AWS EC2 & Executing Bootstrap Script](#step-3-provisioning-aws-ec2--executing-bootstrap-script)
4. [Step 4: Jenkins Installation & Credential Configuration](#step-4-jenkins-installation--credential-configuration)
5. [Step 5: Configuring GitHub Webhook & Pipeline Job](#step-5-configuring-github-webhook--pipeline-job)
6. [Step 6: Executing Zero-Touch Deployment (`git push`)](#step-6-executing-zero-touch-deployment-git-push)
7. [🎓 Top 10 Technical Interview Questions & Senior Engineer Answers](#-top-10-technical-interview-questions--senior-engineer-answers)

---

## Step 1: Local Java & Maven Build Verification

### 1.1 Why build locally first?
Before pushing code to a remote CI server like Jenkins, every engineer verifies that the source code compiles cleanly and unit tests pass locally. If local compilation fails, remote CI will fail.

### 1.2 Execution Command
Open your terminal in the `application/` directory and execute:

```bash
cd application
mvn clean test package
```

### 1.3 What Maven Does Internally
1. `clean`: Deletes the `target/` directory to clear old compiled `.class` files.
2. `test`: Compiles Java sources and runs JUnit 5 test classes (`DevopsApplicationTests.java`).
3. `package`: Bundles compiled bytecode into `target/devops-app-1.0.0-SNAPSHOT.jar`.

---

## Step 2: Multi-Stage Docker Container Verification

### 2.1 Why Multi-Stage Dockerfile?
A single-stage Dockerfile using full Java JDK produces image sizes around ~600MB - 1GB. Our multi-stage [Dockerfile](file:///d:/Projects/DevProj/docker/Dockerfile) uses Maven JDK to compile in **Stage 1 (Builder)**, then copies only the runnable JAR into Alpine JRE in **Stage 2 (Runner)**. This reduces image size to **~150MB**.

### 2.2 Execution Commands
From the project root directory (`d:\Projects\DevProj`):

```bash
# 1. Build Docker image
docker build -f docker/Dockerfile -t devops-app:local .

# 2. Run container locally
docker run -d --name devops-local -p 8080:8080 devops-app:local

# 3. Test HTTP health endpoint
curl http://localhost:8080/health

# Output should return:
# {"status":"UP","service":"project-jugaad-api","timestamp":"...","deploymentMode":"Zero-Touch CI/CD Automated"}

# 4. Cleanup local container
docker stop devops-local && docker rm devops-local
```

---

## Step 3: Provisioning AWS EC2 & Executing Bootstrap Script

### 3.1 Launch AWS EC2 Instance (Free Tier)
1. Log into AWS Console -> Go to **EC2 Dashboard**.
2. Click **Launch Instance**:
   - **Name:** `jugaad-prod-server`
   - **OS Image:** Ubuntu Server 22.04 LTS (64-bit x86)
   - **Instance Type:** `t2.micro` (or `t3.micro`) - Free Tier Eligible.
   - **Key Pair:** Create or select an existing `.pem` key pair (e.g., `jugaad-key.pem`).
   - **Network Settings (Security Group):**
     - Allow SSH (TCP 22) from Anywhere or My IP.
     - Allow Custom TCP (Port 8080) from Anywhere (`0.0.0.0/0`).
3. Click **Launch Instance**. Copy the **Public IPv4 Address** (e.g., `54.210.10.20`).

### 3.2 Execute Bootstrap Script via SSH
Copy [setup-ec2.sh](file:///d:/Projects/DevProj/scripts/setup-ec2.sh) to your EC2 instance and run it:

```bash
# SSH into EC2 instance
ssh -i "jugaad-key.pem" ubuntu@<YOUR_EC2_PUBLIC_IP>

# Download or create setup-ec2.sh on server, then make executable:
chmod +x setup-ec2.sh
./setup-ec2.sh
```

**What setup-ec2.sh accomplishes:**
- Installs Docker Engine CE and containerd.
- Adds `ubuntu` user to `docker` group.
- Configures **2GB Swap space** on Linux kernel (prevents OOM killer from crashing `t2.micro` instance).

---

## Step 4: Jenkins Installation & Credential Configuration

### 4.1 Installing Jenkins
On your Jenkins server (or locally / dedicated EC2):

```bash
# Install Java 21 OpenJDK
sudo apt-get update
sudo apt-get install -y openjdk-21-jdk

# Add Jenkins GPG Key & Repository
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo gpg --dearmor -o /usr/share/keyrings/jenkins-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update
sudo apt-get install -y jenkins
sudo systemctl enable --now jenkins
```

Access Jenkins at `http://<JENKINS_IP>:8080`.

### 4.2 Required Jenkins Plugins
Go to **Manage Jenkins** -> **Plugins** -> **Available Plugins** and install:
- `Git` plugin
- `Pipeline` plugin
- `SSH Agent` plugin
- `Credentials Binding` plugin

### 4.3 Storing Credentials Securely
Go to **Manage Jenkins** -> **Credentials** -> **System** -> **Global credentials**:

1. **Docker Hub Credentials:**
   - **Kind:** Username with password
   - **ID:** `docker-hub-credentials`
   - **Username:** Your Docker Hub username
   - **Password:** Your Docker Hub access token/password

2. **EC2 SSH Key Credentials:**
   - **Kind:** SSH Username with private key
   - **ID:** `ec2-ssh-private-key`
   - **Username:** `ubuntu`
   - **Private Key:** Paste raw content of `jugaad-key.pem`

---

## Step 5: Configuring GitHub Webhook & Pipeline Job

### 5.1 Create Jenkins Pipeline Job
1. Click **New Item** -> Name: `project-jugaad-pipeline` -> Select **Pipeline** -> Click OK.
2. Under **Build Triggers**, check **GitHub hook trigger for GITScm polling**.
3. Under **Pipeline Definition**, select **Pipeline script from SCM**:
   - **SCM:** Git
   - **Repository URL:** `https://github.com/<your-username>/project-jugaad.git`
   - **Branch Specifier:** `*/main`
   - **Script Path:** `jenkins/Jenkinsfile`
4. Click **Save**.

### 5.2 Configure Webhook in GitHub
1. Open your GitHub Repository -> **Settings** -> **Webhooks** -> **Add webhook**.
2. **Payload URL:** `http://<YOUR_JENKINS_IP>:8080/github-webhook/`
3. **Content type:** `application/json`
4. **Which events?** Just the `push` event.
5. Click **Add webhook**.

---

## Step 6: Executing Zero-Touch Deployment (`git push`)

Now test the complete zero-touch flow!

```bash
# 1. Update application code (e.g. edit version string in HealthController.java)
git add .
git commit -m "feat: updated health check response metadata"

# 2. Push to GitHub
git push origin main
```

### What happens automatically:
1. GitHub fires Webhook to Jenkins.
2. Jenkins checks out `main` branch.
3. Jenkins runs `mvn clean test` (compiles and passes unit tests).
4. Jenkins packages JAR and builds Docker image `username/devops-app:latest`.
5. Jenkins logs in and pushes image to Docker Hub.
6. Jenkins opens SSH session to AWS EC2 and executes [deploy.sh](file:///d:/Projects/DevProj/scripts/deploy.sh).
7. `deploy.sh` pulls latest image, stops old container, launches new container on port 8080.
8. Application is updated live at `http://<EC2_PUBLIC_IP>:8080/health`!

---

## 🎓 Top 10 Technical Interview Questions & Senior Engineer Answers

### Q1: "Why did you use a Multi-Stage Dockerfile instead of a single stage?"
> **Senior Engineer Answer:**  
> "A single-stage Dockerfile includes build tools like Maven and full JDK in the final image, resulting in image sizes over 600MB with a large security attack surface. By using a multi-stage Dockerfile, Stage 1 handles compilation in Maven JDK, and Stage 2 copies only the compiled JAR into a lightweight Alpine JRE runtime (~150MB). This dramatically reduces network transfer time during deployment and enhances security."

### Q2: "How did you prevent Out-Of-Memory (OOM) crashes on AWS Free Tier EC2?"
> **Senior Engineer Answer:**  
> "AWS `t2.micro` provides only 1GB RAM. Running Maven, Docker builds, or Java applications can trigger the Linux OOM Killer. I solved this by configuring a 2GB Linux Swap space on the kernel as a virtual memory safety buffer, and setting JVM memory bounds (`-Xms128m -Xmx256m`) inside the Docker container."

### Q3: "How does your deployment achieve zero manual intervention?"
> **Senior Engineer Answer:**  
> "We implemented GitHub Webhooks integrated with a Declarative `Jenkinsfile`. When a developer pushes code to `main`, GitHub sends a webhook POST payload to Jenkins. Jenkins triggers a 6-stage pipeline: Checkout, Maven Compile/Test, Package, Docker Build, Registry Push, and SSH Deployment. The deployment script `deploy.sh` runs remotely via SSH to pull the new container and perform zero-downtime container replacement."

### Q4: "Where are sensitive credentials stored in your CI/CD architecture?"
> **Senior Engineer Answer:**  
> "Zero plaintext credentials exist in our source code or git repository. Docker Hub passwords and SSH private keys are stored securely inside the encrypted Jenkins Credentials Store and injected into pipeline stages dynamically using Jenkins `withCredentials` binding wrappers."

### Q5: "What happens if a developer pushes code that breaks unit tests?"
> **Senior Engineer Answer:**  
> "Stage 2 of our Jenkins pipeline runs `mvn clean test`. If any unit test fails, Maven returns a non-zero exit code, immediately halting the pipeline. Stages 3–6 (Packaging, Docker Build, Push, Deploy) are aborted, ensuring bad code never reaches Docker Hub or the production EC2 server."

### Q6: "Why did you choose self-hosted Jenkins over GitHub Actions for Version 1?"
> **Senior Engineer Answer:**  
> "While GitHub Actions handles server management automatically, self-hosting Jenkins provided deep hands-on experience in CI engine administration, SSH key management, credential isolation, and agent executor mechanics—skills required for enterprise DevOps roles."

### Q7: "How do you handle container log inspection and troubleshooting on EC2?"
> **Senior Engineer Answer:**  
> "Our deployment script `deploy.sh` verifies container status after startup. If `docker ps` shows the container failed to launch, the script captures `docker logs devproj-app`, outputs the failure stack trace directly to the Jenkins build console, and exits with code 1 to alert the team."

### Q8: "How do you manage disk space on the target EC2 server with frequent deployments?"
> **Senior Engineer Answer:**  
> "Continuous container builds leave old, untagged images on disk. Our deployment script executes `docker image prune -f` at the end of every successful deployment to remove dangling image layers and prevent EBS storage exhaustion."

### Q9: "Why didn't you include Kubernetes or Terraform in Version 1?"
> **Senior Engineer Answer:**  
> "In software architecture, over-engineering early leads to unnecessary complexity and cost. For a single microservice on AWS Free Tier, Kubernetes adds massive resource overhead (exceeding 1GB RAM limits). Establishing a solid core pipeline with Docker, Jenkins, and SSH laid the mandatory foundation before scaling to Kubernetes or Terraform in Version 2."

### Q10: "How is security handled inside your Docker container runtime?"
> **Senior Engineer Answer:**  
> "Inside our Dockerfile, we explicitly create a non-root system group and user (`appgroup`/`appuser`) and execute `USER appuser`. Running applications as non-root prevents container breakout vulnerabilities where an attacker could gain host root access."
