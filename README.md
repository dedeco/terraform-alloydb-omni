
# AlloyDB Omni on Google Compute Engine Quickstart - Terraform

AlloyDB Omni is a standalone, downloadable version of our managed service, AlloyDB, which is fully PostgreSQL compatible and has improved performance across the boards with extra emphasis on improving analytical queries. AlloyDB Omni can run on any x86 Linux system.

This [video](https://www.youtube.com/watch?v=GO5ms7szN8M) walks through creating a Google Compute Engine virtual machine with the startup script metadata tag to create a one-step creation flow that will stand up an AlloyDB Omni machine ready to go on Google Cloud.

Shell startup script in GitHub  → https://goo.gle/3ZPuM25
Documentation for GCE startup scripts → https://goo.gle/46HQ97S


## Commands

This repository contains Terraform configuration files to provision an AlloyDB Omni instance on Google Cloud Platform. This offers an alternative approach (with same result) to the methods demonstrated in the following video: [link](https://www.youtube.com/watch?v=GO5ms7szN8M)

### Prerequisites
- A Google Cloud Platform project with billing enabled.
- Terraform installed on your local system (https://www.terraform.io/downloads)

#### Setup

Clone the Repository
```
git clone https://github.com/dedeco/terraform-alloydb-omni
```


Navigate to the Project Directory

```
cd terraform-alloydb-omni/
```

Set Your Google Cloud Project ID. Replace YOUR_PROJECT_ID with the actual ID of your Google Cloud project.
```
export GOOGLE_CLOUD_PROJECT=YOUR_PROJECT_ID
```

Initialize Terraform. This command downloads necessary plugins and modules.

```
terraform init
```

Review the Execution Plan. This generates a detailed plan showing the resources Terraform will create, modify, or delete. Carefully review this output before proceeding.
```
terraform plan
```

Apply the Changes. This command executes the plan and provisions your AlloyDB instance along with any related infrastructure. Type yes when prompted to confirm.

```
terraform apply
```

### Additional Notes
- Customization: You may need to modify the Terraform configuration files (.tf files) to tailor the Compute engine instance to your specific requirements (e.g., disk size, region, etc.).

- Permissions: Ensure your Google Cloud account has the necessary permissions to create Compute engine instances and related resources.

- Cost: Be mindful that Compute engine is a billable service. Refer to Google Cloud pricing for details.


