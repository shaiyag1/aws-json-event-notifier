# AWS JSON Event Notifier 📬

A fully serverless event-driven system on AWS:
- Upload `.json` files to **S3**
- Trigger a **Lambda** function
- Send notifications via **SNS** (email alerts)

## 🛠️ Stack
- AWS S3
- AWS Lambda (Python 3.12)
- AWS SNS (Simple Notification Service)
- Terraform (Infrastructure as Code)

## 📂 Project Structure
```plaintext
.
├── main.tf             # Terraform provider and backend setup
├── s3.tf               # S3 bucket and trigger configuration
├── lambda.tf           # Lambda function definition and environment variables
├── iam.tf              # IAM roles and permissions for Lambda
├── sns.tf              # SNS topic and email
