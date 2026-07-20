# Project Jugaad: Zero-Touch Java CI/CD Pipeline

> A production-style, zero-touch automated DevOps deployment pipeline for Java Spring Boot applications on AWS Free Tier infrastructure.

---

## 📌 Project Overview
**Project Jugaad** (Sanskrit/Hindi for *frugal, smart engineering solution*) is a complete hands-on DevOps architecture designed to take a Java Spring Boot application from local Git commit to live cloud deployment on AWS EC2 without any manual deployment commands.

---

## 🏗️ Architecture Blueprint

```
Developer Push ──> GitHub ──> Webhook ──> Jenkins CI ──> Maven Build & Test
                                               │
                                               ▼
Browser Client <── AWS EC2 Container <── Docker Hub <── Docker Image Build
```

For complete low-level architectural specs, component interaction diagrams, sequence flows, and network security group settings, see [Comprehensive System Design Specification](file:///d:/Projects/DevProj/docs/architecture/design-spec.md).

---

## 🛠️ Technology Stack
- **Application:** Java 21, Spring Boot, Maven
- **Version Control:** Git, GitHub
- **CI Engine:** Jenkins (Self-Hosted)
- **Containerization:** Docker, Docker Hub
- **Cloud Infrastructure:** AWS EC2 (Ubuntu 22.04 LTS)
- **Deployment Mechanism:** SSH Remote Script Execution

---

## 📁 Repository Structure
```
project-jugaad/
├── README.md                           # Master Project Overview
├── LICENSE                             # MIT License
├── .gitignore                          # Git exclusions
├── docs/                               # Engineering Documentation
│   └── architecture/
│       └── design-spec.md              # System Architecture & Design Specification
├── application/                        # Java Spring Boot App
├── docker/                             # Dockerfile & container assets
├── jenkins/                            # Jenkinsfile declarative pipeline
└── scripts/                            # EC2 deployment scripts
```

---

## 🛣️ Development Phases
- [x] **Phase 1-4:** Requirement Analysis, System Design & Architecture Specification
- [ ] **Phase 5-6:** Java Application Development & Maven Testing
- [ ] **Phase 7:** AWS EC2 Environment Provisioning
- [ ] **Phase 8-9:** Docker Containerization & Docker Hub Registry Integration
- [ ] **Phase 10-12:** Jenkins CI/CD Pipeline & SSH Deployment Automation
- [ ] **Phase 13-15:** Pipeline Verification, Edge-Case Hardening & Final Documentation

---

## 👤 Mentorship & Author
Designed and maintained under Senior DevOps Architecture mentorship.
