# Elixirjuju

An experimental library to provide a client to the Juju (https://juju.ubuntu.com/) API

Example usage of this library  would be:
```elixir
pid = Elixirjuju.start("url", "admin-secret")
pid <- Elixirjuju.deploy("wordpress", "cs:precise/wordpress", 1)
pid <- Elixirjuju.deploy("mysql", "cs:precise/mysql", 1)        
pid <- Elixirjuju.add_relation("wordpress", "mysql")
```

This would connect to the juju bootstrap node, then deploy wordpress and mysql charms and connect the two togther
