terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

# CONTENEDOR PARA API HELLO WORLD
resource "docker_container" "app1" {
  name  = "app1"
  image = "awesome-flask"

  ports {
    internal = "8000"
    external = "8000"
  }
}

# CONTENEDOR PARA BASE DE DATOS NO RELACIONAL MONGODB
resource "docker_container" "mongodb" {
  name  = "mongodb"
  image = "mongodb/mongodb-community-server:latest"
  ports {
    internal = "27017"
    external = "27017"
  }
}

# CONTENEDOR FRONT
resource "docker_volume" "html" {
  name = "html-volume"
}


# CONTENEDOR PARA NGNIX + FRONT
resource "docker_container" "nginx" {
  name  = "nginx"
  image = "nginx"

  ports {
    internal = "80"
    external = "8083"
  }

  volumes {
    volume_name    = docker_volume.html.name
    host_path      = "/html" 
    container_path = "/usr/share/nginx/html"
    read_only     = true
  }
}


# CONTENEDOR DE REACT
/* resource "docker_image" "react" {
  name = "my-react-app:latest"

  build {
    path = "."
  }
}

resource "docker_container" "react" {
  image = docker_image.react.latest

  ports {
    internal = 80
    external = 8085
  }
}
*/

#CONTENEDOR BACK
resource "docker_container" "sql" {
  name  = "sql"
  image = "mysql"
  env = [
	"MYSQL_ROOT_PASSWORD=root"
  ]

  ports {
    internal = "3306"
    external = "3307"
  }
}

# CONTENEDOR FRONT WORDPRESS
resource "docker_container" "wordpress" {
  name  = "wordpress"
  image = "wordpress"
  restart = "unless-stopped"

  ports {
    internal = 80
    external = 8081
  }

  env = [
    "WORDPRESS_DB_HOST=${docker_container.sql.name}:3307",
    "WORDPRESS_DB_USER=root",
    "WORDPRESS_DB_PASSWORD=root",
    "WORDPRESS_DB_NAME=docker",
  ]

  depends_on = [
    docker_container.sql,
  ]
}