# NSWI130 - Software system architectures

Semmester project, describing the architecture of a drug monitoring software system in a hospital.


## Running Structurizr

### Linux with Docker

You can start the structurizr lite by running:

    make run

And you can access it via web browser at [http://localhost:8080/](http://localhost:8080/).

> **Note:** Structurizr container runs as root and thus the files it creates are owned by root. You can own back these files by running: `sudo make chown`. The `make run` command automatically touches the `workspace.json` file to make sure this file is created belonging to us, not the root.


### Windows with Docker

> To be filled out by the first windows user to need this.


## Domain Language

The lists of all domain language terms in both czech and english. The list is alphabetically sorted by english. Do not use czech terms in this repository, only for communication with the outside world.

- `english term | czech term` The meaning of the term.
- TODO
