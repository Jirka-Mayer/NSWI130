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

- `(Drug) Package | Balení` One package of a given drug (one physical box with many pills inside).
- `(Drug) Request | Poptávka` Hospital wards request drugs from the warehouse - this the request.
- `(Hospital) Employee | Zaměstnanec` Any employee of the hospital, can view package state.
- `(Hospital) Ward | Oddělení` One department of the hospital. It requests drug packages.
- `(Package) Arrival | Přijetí balení na oddělení` The moment when a drug package arrives at the target ward and the arrival is recorded into the system.
- `Depletion | Spotřebování` When a drug package becomes empty.
- `Order | Objednávka` An order placed to the supplier.
- `Storekeeper | Skladník` The person responsible for ordering drugs from suppliers.
- `Supplier | Dodavatel` An external business that sells drugs to us. We order drugs via their API.
- `To Stock | Naskladnit` To put new items into the warehouse.
- `To Unstock | Vyskladnit` To remove items from the warehouse.
- `Ward Worker | Pracovník nemocničního oddělení` Can request drug packages, record their arrival and their depletion.
- `Warehouse | Sklad` The place where drug packages are kept before being distributed to individual hospital wards.
- `Warehouse Worker | Pracovník Skladu` Stocks and unstocks drug packages.
- ~~`Stocking Operator | Naskladňovatel` The person responsible for stocking new packages.~~
- ~~`Unstocking Operator | Vyskladňovatel` The person responsible for unstocking packages.~~