{
  lib,
  alcotest,
  buildDunePackage,
  cmdliner,
  digestif,
  fmt,
  fpath,
  hex,
  irmin,
  irmin-pack,
  irmin-test,
  ppx_irmin,
  tezos-base58,
  yojson,
}:

buildDunePackage {
  inherit (irmin) version src;
  pname = "irmin-tezos";

  buildInputs = [
    cmdliner
    yojson
  ];

  propagatedBuildInputs = [
    irmin
    irmin-pack
    ppx_irmin
    digestif
    fmt
    tezos-base58
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    hex
    irmin-test
    fpath
  ];

  meta = irmin.meta // {
    description = "Irmin implementation of the Tezos context hash specification";
    maintainers = [ lib.maintainers.ulrikstrid ];
  };
}
