
# Fider on AWS ECS — Terraform & CI/CD

A production-style deployment of the open-source **Fider** feedback platform on AWS, built to demonstrate practical DevOps and cloud engineering skills using **Docker, Terraform, Amazon ECS/Fargate, RDS PostgreSQL, Application Load Balancer, Route 53, HTTPS, GitHub Actions and AWS OIDC authentication**.

The project started with running Fider locally using Docker and progressed through manual AWS deployment, Infrastructure as Code with Terraform, and finally an automated CI/CD pipeline that builds and deploys new application versions to Amazon ECS.

## Architecture

```text
                         Internet
                            |
                            v
                  Route 53 DNS
                fider.harrydev.net
                            |
                            v
                    HTTPS / TLS
                       AWS ACM
                            |
                            v
              Application Load Balancer
                    HTTP 80 -> 443
                            |
                            v
                    ECS / Fargate
                      Fider App
                      Port 3000
                            |
                            v
                   RDS PostgreSQL
                  Private DB Subnets


GitHub
   |
   | Push to main
   v
GitHub Actions
   |
   | OIDC Authentication
   v
AWS IAM
   |
   +----> Docker Build
   |
   +----> Amazon ECR
   |
   +----> ECS Task Definition
   |
   +----> ECS Service Deployment
   |
   +----> Production Health Check
```

## Project Overview

The objective of this project was to take a real open-source application and implement a production-style AWS deployment lifecycle.

The project covers:

- Running Fider locally with Docker
- Containerising the application
- Deploying the application to Amazon ECS using Fargate
- Storing container images in Amazon ECR
- Using Amazon RDS PostgreSQL for the application database
- Placing the application behind an Application Load Balancer
- Configuring HTTPS using AWS Certificate Manager
- Configuring a custom domain using Route 53
- Managing AWS infrastructure using Terraform
- Storing sensitive application configuration in AWS Secrets Manager
- Sending application logs to CloudWatch
- Implementing automated deployments using GitHub Actions
- Authenticating GitHub Actions to AWS using OIDC rather than long-lived AWS access keys
- Performing a production health check after deployment

## Technology Stack

| Technology | Purpose |
|---|---|
| AWS ECS | Container orchestration |
| AWS Fargate | Serverless container compute |
| Amazon ECR | Docker image registry |
| Amazon RDS | PostgreSQL database |
| Application Load Balancer | Application traffic distribution |
| AWS Certificate Manager | TLS certificate management |
| Route 53 | DNS management |
| AWS Secrets Manager | Application secrets |
| CloudWatch Logs | Container logging |
| AWS IAM | AWS permissions and workload identity |
| Terraform | Infrastructure as Code |
| Docker | Application containerisation |
| GitHub Actions | CI/CD automation |
| GitHub OIDC | Keyless AWS authentication |
| PostgreSQL | Application database |
| NGINX | Local reverse proxy |

## Repository Structure

```text
ECS_FIDER_APP/
|
├── .github/
│   └── workflows/
│       └── deploy.yml
|
├── fider/
│   ├── app/
│   ├── docs/
│   ├── e2e/
│   ├── locale/
│   ├── migrations/
│   ├── public/
│   ├── scripts/
│   ├── static/
│   ├── views/
│   ├── docker-compose.yml
│   ├── go.mod
│   ├── package.json
│   ├── LICENSE
│   └── README.md
|
├── terraform/
│   ├── acm.tf
│   ├── alb.tf
│   ├── cloudwatch.tf
│   ├── ecr.tf
│   ├── ecs.tf
│   ├── iam.tf
│   ├── outputs.tf
│   ├── private-subnets.tf
│   ├── providers.tf
│   ├── rds.tf
│   ├── route53.tf
│   ├── secrets.tf
│   ├── security-groups.tf
│   ├── variables.tf
│   └── vpc.tf
|
├── Dockerfile
├── docker-compose.local.yml
├── nginx.conf
├── .dockerignore
├── .gitignore
└── README.md
```

The upstream Fider application source is kept under `fider/`, while the root of the repository contains the infrastructure, deployment and CI/CD configuration created for this project.

## AWS Infrastructure

### Networking

The application runs inside a custom AWS VPC.

The network contains:

- Two public subnets across separate Availability Zones for the ECS/ALB layer
- Two private database subnets for Amazon RDS
- Internet Gateway
- Public route table
- Dedicated security groups for the ALB, ECS tasks and RDS

Security group traffic is restricted by application layer:

```text
Internet
   |
   | 80 / 443
   v
ALB Security Group
   |
   | TCP 3000
   v
ECS Security Group
   |
   | PostgreSQL 5432
   v
RDS Security Group
```

The database is therefore not directly exposed to the public internet.

## Amazon ECS / Fargate

Fider runs as a containerised workload on Amazon ECS using the Fargate launch type.

The ECS task is configured with:

- 1 vCPU
- 2 GB memory
- Container port `3000`
- CloudWatch logging
- AWS Secrets Manager integration
- Application environment variables
- Application Load Balancer integration

The ECS service maintains the desired application task and deploys new task definition revisions during CI/CD releases.

## Amazon RDS

The application uses PostgreSQL hosted by Amazon RDS.

The database is deployed into dedicated private database subnets and only accepts PostgreSQL traffic from the ECS security group.

Database credentials are not hard-coded into the ECS task definition. The application database connection string is retrieved from AWS Secrets Manager at runtime.

## Secrets Management

Sensitive configuration is stored using AWS Secrets Manager.

The ECS task retrieves:

- `DATABASE_URL`
- `JWT_SECRET`

through the ECS task execution role.

This prevents application secrets from being stored directly inside the Docker image or committed to the repository.

## Application Load Balancer

The Application Load Balancer provides the public entry point for Fider.

Traffic flow:

```text
HTTP :80
   |
   v
301 Redirect
   |
   v
HTTPS :443
   |
   v
Target Group
   |
   v
Fider :3000
```

The target group uses the Fider health endpoint:

```text
/_health
```

to determine whether ECS tasks are healthy and able to receive traffic.

## HTTPS and Custom Domain

The application is available using the custom domain:

```text
https://fider.harrydev.net
```

AWS Certificate Manager provides the TLS certificate used by the HTTPS ALB listener.

Route 53 provides DNS resolution and maps the Fider subdomain to the Application Load Balancer.

## Infrastructure as Code

The AWS infrastructure is managed using Terraform.

Typical workflow:

```bash
cd terraform

terraform fmt
terraform validate
terraform plan
terraform apply
```

Terraform manages the core infrastructure including:

- VPC
- Subnets
- Internet Gateway
- Route tables
- Security groups
- ECR repository
- ECS cluster
- ECS task definition baseline
- ECS service
- RDS
- Application Load Balancer
- Target group
- ALB listeners
- Route 53 record
- CloudWatch log group
- Secrets Manager resources
- ECS IAM permissions

After the infrastructure was imported and aligned with Terraform, the configuration reached:

```text
No changes. Your infrastructure matches the configuration.
```

This provides a reproducible Infrastructure as Code baseline rather than relying on manual AWS console configuration.

## CI/CD Pipeline

Application deployments are automated using GitHub Actions.

The deployment workflow is triggered by a push to the `main` branch.

```text
Developer
   |
   | git push
   v
GitHub
   |
   v
GitHub Actions
   |
   +--> Authenticate to AWS using OIDC
   |
   +--> Build Docker image
   |
   +--> Tag image using Git commit SHA
   |
   +--> Push image to Amazon ECR
   |
   +--> Retrieve current ECS task definition
   |
   +--> Replace container image
   |
   +--> Register new task definition revision
   |
   +--> Update ECS service
   |
   +--> Wait for service stability
   |
   +--> Run production health check
```

Using the Git commit SHA as the image tag provides traceability between a running ECS deployment and the source revision that produced it.

## GitHub Actions and AWS OIDC

The CI/CD pipeline uses GitHub's OpenID Connect integration with AWS.

Instead of storing permanent AWS access keys as GitHub secrets, GitHub Actions requests a temporary identity token.

```text
GitHub Actions
      |
      | OIDC token
      v
AWS IAM OIDC Provider
      |
      v
IAM Deployment Role
      |
      v
Temporary AWS Credentials
```

The deployment role is restricted to the permissions required by the pipeline, including:

- Push images to the Fider ECR repository
- Read and register ECS task definitions
- Update the Fider ECS service
- Pass the ECS task execution role

This removes the requirement for long-lived AWS credentials inside GitHub.

## Terraform and CI/CD Ownership

An important design consideration was preventing Terraform and GitHub Actions from competing over ECS task definition revisions.

Terraform manages the ECS service infrastructure and establishes the baseline task definition.

GitHub Actions manages application releases by registering new task definition revisions containing new Docker image versions.

The Terraform ECS service therefore uses:

```hcl
lifecycle {
  ignore_changes = [
    task_definition
  ]
}
```

This prevents a later `terraform apply` from rolling the ECS service back to an older application task revision deployed by Terraform.

The resulting responsibility model is:

```text
Terraform
   |
   +--> AWS Infrastructure
   +--> ECS Service
   +--> Baseline Task Definition

GitHub Actions
   |
   +--> Application Image
   +--> New Task Definition Revisions
   +--> Application Releases
```

## Monitoring and Health Checks

Fider application logs are sent to:

```text
/ecs/fider
```

in Amazon CloudWatch Logs.

The project uses the application endpoint:

```text
/_health
```

for both ALB target health checks and post-deployment CI/CD verification.

A successful production check returns:

```json
{"status":"Healthy"}
```

This means a successful pipeline does more than push an image—it verifies that the newly deployed application is reachable and healthy.

## Troubleshooting and Lessons Learned

### ECS Task Failed After Deployment

During implementation, the CI/CD pipeline successfully:

- Authenticated to AWS
- Built the Docker image
- Pushed the image to ECR
- Registered an ECS task definition

However, the new ECS task exited with:

```text
Essential container in task exited
Exit code: 2
```

CloudWatch Logs were used to identify the actual application error:

```text
failed to parse environment variables
the environment variable "EMAIL_NOREPLY" is missing
```

The existing working ECS task definition was compared with the Terraform configuration. The missing Fider email environment variables were then added to the Terraform task definition.

This demonstrated the importance of checking application logs rather than treating an ECS task failure as purely an infrastructure issue.

### GitHub OIDC Authentication

The first GitHub Actions deployment failed when attempting to assume the AWS IAM deployment role:

```text
Not authorized to perform sts:AssumeRoleWithWebIdentity
```

The IAM trust relationship was corrected so that the GitHub repository identity could assume the deployment role.

After correcting the trust configuration, GitHub Actions successfully obtained temporary AWS credentials without requiring stored AWS access keys.

### Terraform vs CI/CD Task Definition Drift

Once GitHub Actions started registering new ECS task definition revisions, Terraform could detect a different task revision from its original baseline.

The ECS service lifecycle configuration was updated so Terraform ignores application task revision changes.

This established a clear separation between:

- infrastructure lifecycle management
- application deployment lifecycle management

and prevents Terraform from unintentionally reverting a successful CI/CD release.

## Local Development

The application can also be run locally using Docker.

The local environment includes:

- Fider
- PostgreSQL
- MailHog
- NGINX

Build the application image:

```bash
docker build -t fider-app:local .
```

Start the local environment:

```bash
docker compose -f docker-compose.local.yml up -d
```

Check running containers:

```bash
docker ps
```

The NGINX reverse proxy exposes the application locally over port `80`.

## Deployment Verification

The production application health endpoint can be checked with:

```bash
curl https://fider.harrydev.net/_health
```

Expected response:

```json
{"status":"Healthy"}
```

ECS service status can also be checked using the AWS CLI:

```bash
aws ecs describe-services \
  --cluster Fider-Cluster \
  --services fider-service \
  --region eu-west-2
```

## Screenshots

Screenshots can be added here to demonstrate the deployed infrastructure and pipeline.

Suggested evidence:

1. Live Fider application
2. GitHub Actions successful deployment
3. ECS service running
4. ECS task definition
5. Application Load Balancer target health
6. ECR image repository
7. RDS database
8. Route 53 DNS record
9. CloudWatch application logs
10. Terraform plan showing no infrastructure drift

## Future Improvements

Potential improvements to the project include:

- Run ECS tasks in private subnets with controlled outbound connectivity
- Add ECS Service Auto Scaling
- Introduce remote Terraform state
- Add Terraform state locking
- Manage the GitHub OIDC IAM resources with Terraform
- Add infrastructure security scanning to CI
- Add container vulnerability scanning
- Add automated application/integration testing before production deployment
- Add CloudWatch alarms and SNS notifications
- Add enhanced deployment strategies such as blue/green deployment

These are intentionally listed as future improvements rather than features already implemented.

## Key Skills Demonstrated

This project demonstrates practical experience with:

- AWS cloud infrastructure
- Docker containerisation
- Amazon ECS and Fargate
- Infrastructure as Code with Terraform
- Amazon RDS PostgreSQL
- AWS networking and security groups
- Application Load Balancers
- HTTPS and TLS certificates
- Route 53 DNS
- AWS IAM
- AWS Secrets Manager
- CloudWatch troubleshooting
- GitHub Actions
- CI/CD pipelines
- GitHub OIDC federation
- Linux and command-line tooling
- Git and GitHub
- Production troubleshooting

## Upstream Application

This project uses **Fider**, an open-source customer feedback platform, as the application workload.

The upstream Fider source code and its original project documentation are retained under:

```text
fider/
```

The Fider source remains subject to its upstream licence, preserved in:

```text
fider/LICENSE
```

This repository focuses on the containerisation, AWS infrastructure, Infrastructure as Code and CI/CD implementation surrounding the application.
