📌 **Author:** Mohamed A Mohamed   
🚀 **Email:** mohamed0395@gmail.com


![image](https://imgur.com/kmtCGj0.png)
# Securing AWS S3 with Terraform

## Introduction

In today's cloud-driven world, security is paramount. As part of my journey into DevSecOps, I embarked on a project to secure an AWS S3 bucket using Terraform while ensuring compliance with security best practices. This documentation highlights the steps taken, challenges faced, and lessons learned along the way.

## Tech Stack
- **Terraform**: Infrastructure as Code (IaC) tool
- **AWS S3**: Object storage for secure data storage
- **AWS KMS**: Key Management Service for encryption
- **AWS IAM**: Identity and Access Management for security policies
- **AWS CloudTrail & Logging**: Audit and monitoring capabilities
- **tfsec & checkov**: Security scanning tools for Terraform
- **GitHub Actions (Planned)**: Future integration for CI/CD security automation

## Objectives

The primary goals of this project were to:
- Deploy a secure AWS S3 bucket using Terraform.
- Implement security measures such as encryption, logging, and access restrictions.
- Use security scanning tools (`tfsec` and `checkov`) to identify and remediate misconfigurations.
- Document the entire process for learning and sharing with others.

## Initial Setup

To begin, I set up my environment with the following tools:
- **AWS CLI** configured with appropriate IAM permissions.
- **Terraform** (v1.0+).
- **Security Scanning Tools**: `tfsec` and `checkov`.

## Implementing Security Measures

### **1. Blocking Public Access**
To ensure that the S3 bucket and its objects were never exposed publicly, I implemented strict public access blocking policies:
```hcl
resource "aws_s3_bucket_public_access_block" "secure_bucket" {
  bucket                  = aws_s3_bucket.secure_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

![image](https://imgur.com/1w6QAwX.png)

### **2. Enabling Encryption**
![image](https://imgur.com/TLxpvjT.png)
To protect data at rest, I enforced server-side encryption using AWS KMS:
```hcl
resource "aws_kms_key" "s3_key" {
  description         = "KMS key for S3 encryption"
  enable_key_rotation = true
}
```
![image](https://imgur.com/ZBQHfzK.png)

This ensured that all stored data was encrypted using a customer-managed key.

### **3. Enabling Logging for Auditability**
To maintain an audit trail of bucket access, I enabled logging:
```hcl
resource "aws_s3_bucket_logging" "logging" {
  bucket        = aws_s3_bucket.secure_bucket.id
  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}
```
Logging provides valuable insights into access patterns and potential security threats.
![image](https://imgur.com/nlomRad.png)

### **4. Enabling Versioning**
Versioning was enabled to preserve object history and recover from accidental deletions:
```hcl
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.secure_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
```
![image](https://imgur.com/v5mGmtq.png)
## Security Scanning & Remediation

### **1. Running `tfsec`**
To scan Terraform configurations for security vulnerabilities, I used `tfsec`:
```bash
tfsec .
```
![image](https://imgur.com/yIGWiEf.png)
Initially, it detected missing encryption settings, which I addressed by ensuring that all S3 buckets were encrypted using KMS.
![image](https://imgur.com/TEQQzM9.png)
### **2. Running `checkov`**
I also ran `checkov` to validate compliance against security best practices:
```bash
checkov -d .
```
![image](https://imgur.com/lyaLjjG.png)
This tool flagged improper access controls, which I resolved by enforcing stricter policies.
![image](https://imgur.com/54nVXNg.png)

## Challenges Faced & Solutions

### **1. Duplicate Terraform Resources**
- **Issue:** Initially, I had multiple declarations of resources such as `aws_kms_key` and `aws_s3_bucket_public_access_block`.
- **Solution:** Cleaned up duplicate resources and ensured uniqueness across Terraform configurations.

### **2. Public Access Misconfigurations**
- **Issue:** Some configurations did not correctly restrict public access.
- **Solution:** Explicitly defined `block_public_acls`, `block_public_policy`, and verified changes via the AWS Console.

### **3. State Management Conflicts**
- **Issue:** Changes made outside of Terraform caused state inconsistencies.
- **Solution:** Ensured all changes were made via Terraform and ran `terraform refresh` when necessary.

### **4. Security Scans Reporting Issues**
- **Issue:** `tfsec` and `checkov` flagged missing encryption and access misconfigurations.
- **Solution:** Implemented AWS KMS encryption and refined access policies.

## Final Outcome

After addressing all detected security vulnerabilities, I achieved:
✅ **Fully secured S3 bucket** with encryption, logging, and access restrictions.
✅ **Successful security scans** with no reported issues.
✅ **Documented best practices** for securing cloud storage using Terraform.

## Conclusion
This project demonstrated the importance of Infrastructure as Code (IaC) in enforcing security best practices. By leveraging Terraform, `tfsec`, and `checkov`, I was able to **proactively secure AWS S3** while following compliance standards.

This journey reinforced my skills in **DevSecOps, cloud security, and Terraform troubleshooting**, preparing me for more advanced security projects.
