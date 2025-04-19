// core module
resource "null_resource" "core_example" {
  provisioner "local-exec" {
    command = "echo core deployed"
  }
}
