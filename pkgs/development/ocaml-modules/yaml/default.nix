{
  lib,
  fetchurl,
  alcotest,
  bos,
  buildDunePackage,
  crowbar,
  ctypes,
  dune-configurator,
  ezjsonm,
  fmt,
  junit_alcotest,
  logs,
  mdx,
}:

buildDunePackage rec {
  pname = "yaml";
  version = "3.2.0";

  src = fetchurl {
    url = "https://github.com/avsm/ocaml-yaml/releases/download/v${version}/yaml-${version}.tbz";
    hash = "sha256-xQ0qyii5+WZ5K3HhYDNR5dJO2k39PkRT+9UDZqOggic=";
  };

  buildInputs = [ dune-configurator ];

  propagatedBuildInputs = [
    bos
    ctypes
  ];

  doCheck = true;
  nativeCheckInputs = [ mdx.bin ];

  checkInputs = [
    fmt
    logs
    alcotest
    crowbar
    junit_alcotest
    ezjsonm
  ];

  minimalOCamlVersion = "4.13";

  meta = {
    description = "Parse and generate YAML 1.1 files";
    homepage = "https://github.com/avsm/ocaml-yaml";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };

}
