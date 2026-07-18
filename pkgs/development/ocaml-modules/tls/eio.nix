{
  lib,
  buildDunePackage,
  crowbar,
  eio,
  eio_main,
  logs,
  mdx,
  mirage-crypto-rng,
  ocaml,
  ptime,
  tls,
}:

buildDunePackage {
  inherit (tls) src meta version;
  pname = "tls-eio";

  propagatedBuildInputs = [
    ptime
    eio
    mirage-crypto-rng
    tls
  ];

  doCheck = lib.versionAtLeast ocaml.version "5.1";

  nativeCheckInputs = [
    mdx.bin
  ];

  checkInputs = [
    crowbar
    eio_main
    (mdx.override { inherit logs; })
  ];

  __darwinAllowLocalNetworking = true;
  minimalOCamlVersion = "5.0";
}
