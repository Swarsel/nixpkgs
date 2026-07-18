{
  buildDunePackage,
  logs,
  mirage-block,
}:

buildDunePackage {
  inherit (mirage-block) version src;
  pname = "mirage-block-combinators";

  propagatedBuildInputs = [
    mirage-block
    logs
  ];

  duneVersion = "3";

  meta = mirage-block.meta // {
    description = "Block signatures and implementations for MirageOS using Lwt";

    longDescription = ''
      This repo contains generic operations over Mirage `BLOCK` devices.
      This package is specialised to the Lwt concurrency library for IO.
    '';
  };

}
