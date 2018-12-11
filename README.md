Terraform AWS module for RDS encrypted DB
==================================================

Generic repository for a terraform module for AWS RDS encrypted database, by default Postgres

![Image of Terraform](https://i.imgur.com/Jj2T26b.jpg)

# Table of content

- [Introduction](#intro)
- [Usage](#usage)
- [Release log](#release-log)
- [Module versioning & git](#module-versioning-&-git)
- [Local terraform setup](#local-terraform-setup)
- [Authors/Contributors](#authorscontributors)


# Intro

Module that creates:
- Security Group for RDS, and opens egress traffic on all ports for a given CIDR
- Creates a KMS key (and an alias for it) used to encrypt the RDS instance
- DB subnet and parameter dedicated groups
- DB instance (the RDS)


# Usage

Example usage:

```hcl
module "dev_db_encrypted" {
  source            = "bitbucket.org/geanalytics/terraform-module-aws-storage-rds-encrypted"
  version           = "v0.0.1"

  environment       = "dev"
  project           = "analytics"
  region            = "eu-west-1"
  vpc_id            = "vpc-123"
  subnet_ids        = "subnet-123"
  engine            = "postgres"
  engine_version    = "9.6.6"
  instance_class    = "db.t2.medium"
  db_name           = "mydb"
  username          = "master"
  password          = "supersecret"
  apply_immediately = false
  size              = "20"

  # open SG income traffic for following CIDR blocks
  income_cidr_blocks = [ "10.10.1.0/24" ]
}
```


# Release log

Whenever you bump this module's version, please add a summary description of the changes performed, so that collaboration across developers becomes easier.

* version v0.0.1 - first module release

# Module versioning & git

To update this module please follow the following proceedure:

1) make your changes following the normal git workflow
2) after merging the your changes to master, comes the most important part, namely versioning using tags:

```bash
git tag v0.0.2
```

3) push the tag to the remote git repository:
```bash
git push origin master tag v0.0.2
```

# Local terraform setup

* [Install Terraform](https://www.terraform.io/)

```bash
brew install terraform
```

* In order to automatic format terraform code (and have it cleaner), we use pre-commit hook. To [install pre-commit](https://pre-commit.com/#install).
* Run [pre-commit install](https://pre-commit.com/#usage) to setup locally hook for terraform code cleanup.

```bash
pre-commit install
```


# Authors/Contributors

See the list of [contributors](https://github.com/diogoaurelio/terraform-module-aws-compute-lambda/graphs/contributors) who participated in this project.