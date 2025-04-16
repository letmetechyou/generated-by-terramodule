# AWS VPC Terraform Module

This Terraform module creates a complete AWS VPC infrastructure with subnets, route tables, and Internet Gateway. It provides a simple, configurable way to deploy a standard VPC environment with public and private subnets across multiple availability zones.

## Description

The `aws-vpc-module` creates:

- A Virtual Private Cloud (VPC)
- Public and private subnets spread across multiple availability zones
- Route tables for each subnet type
- An Internet Gateway for public subnet internet access
- Proper route table associations

This module follows AWS best practices for VPC design, allowing you to quickly deploy a secure, scalable network foundation for your AWS resources.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| aws | >= 3.0.0 |

## Usage

### Basic Example

```hcl
module "vpc" {
  source = "github.com/example/aws-vpc-module"

  vpc_name       = "my-vpc"
  vpc_cidr_block = "10.0.0.0/16"

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

  availability_zones = ["us-west-2a", "us-west-2b"]

  tags = {
    Environment = "Development"
    Terraform   = "true"
  }
}
```

### Advanced Example

```hcl
module "vpc" {
  source = "github.com/example/aws-vpc-module"

  vpc_name       = "production-vpc"
  vpc_cidr_block = "10.0.0.0/16"
  
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = "Production"
    Terraform   = "true"
    Project     = "Core Infrastructure"
    Owner       = "Infrastructure Team"
  }

  public_subnet_tags = {
    Tier = "Public"
  }

  private_subnet_tags = {
    Tier = "Private"
  }
}
```

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vpc_name | Name of the VPC | `string` | n/a | yes |
| vpc_cidr_block | CIDR block for the VPC | `string` | n/a | yes |
| public_subnet_cidrs | List of CIDR blocks for public subnets | `list(string)` | `[]` | no |
| private_subnet_cidrs | List of CIDR blocks for private subnets | `list(string)` | `[]` | no |
| availability_zones | List of availability zones to deploy subnets into | `list(string)` | n/a | yes |
| enable_dns_hostnames | Enable DNS hostnames in the VPC | `bool` | `false` | no |
| enable_dns_support | Enable DNS support in the VPC | `bool` | `true` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |
| public_subnet_tags | Additional tags for public subnets | `map(string)` | `{}` | no |
| private_subnet_tags | Additional tags for private subnets | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_cidr_block | The CIDR block of the VPC |
| public_subnet_ids | List of IDs of public subnets |
| private_subnet_ids | List of IDs of private subnets |
| public_route_table_id | ID of the public route table |
| private_route_table_ids | List of IDs of private route tables |
| internet_gateway_id | ID of the Internet Gateway |

## License

This module is licensed under the MIT License - see the LICENSE file for details.