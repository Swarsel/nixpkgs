{
  lib,
  buildDunePackage,
  cmdliner,
  kafka,
  lwt,
  ocaml,
}:

buildDunePackage {
  inherit (kafka) version src;
  pname = "kafka_lwt";
  buildInputs = [ cmdliner ];

  propagatedBuildInputs = [
    kafka
    lwt
  ];

  meta = kafka.meta // {
    description = "OCaml bindings for Kafka, Lwt bindings";
    broken = lib.versionAtLeast ocaml.version "5.0";
  };
}
