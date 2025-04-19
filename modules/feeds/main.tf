// feeds module
resource "null_resource" "feeds_example" {
  provisioner "local-exec" {
    command = "echo feeds deployed"
  }
}
