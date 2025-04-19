// analytics module
resource "null_resource" "analytics_example" {
  provisioner "local-exec" {
    command = "echo analytics deployed"
  }
}
