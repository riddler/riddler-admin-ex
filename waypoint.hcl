project = "riddler-admin"

app "riddler-admin" {
  labels = {
    "service" = "riddler-admin",
    "language" = "elixir",
  }

  build {
    use "docker" {}
  }

  deploy { 
    use "docker" {}
  }
}

app "nsqd" {
  build {
    use "docker-pull" {
      image = "nsqio/nsq"
      tag = "latest"
    }
  }

  deploy {
    use "docker" {
      command      = ["/nsqd"]
      service_port = 4151
    }
  }
}
