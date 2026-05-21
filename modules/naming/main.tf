locals {
  # 環境名の略称マッピング
  env_abbreviations = {
    "engineering-dev" = "edev"
    "dev"             = "dev"
    "stg"             = "stg"
    "prd"             = "prd"
  }

  env_abbr = lookup(local.env_abbreviations, var.environment, var.environment)

  prefix = "${var.project}-${local.env_abbr}"

}
