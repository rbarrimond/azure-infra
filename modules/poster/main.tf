// poster module
resource "null_resource" "poster_example" {
  provisioner "local-exec" {
    command = "echo poster deployed"
  }
}
