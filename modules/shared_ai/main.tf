// shared_ai module
resource "null_resource" "shared_ai_example" {
  provisioner "local-exec" {
    command = "echo shared_ai deployed"
  }
}
