terraform {
  backend "remote" {
    workspaces {
      name = "Publate-infrastructure-prod"
    }
  }
}
