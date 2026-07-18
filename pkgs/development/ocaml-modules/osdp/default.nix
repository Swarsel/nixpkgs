{
  lib,
  fetchurl,
  autoconf,
  buildDunePackage,
  csdp,
  findlib,
  ocaml,
  ocplib-simplex,
  zarith,
}:

buildDunePackage {
  pname = "osdp";
  version = "1.1.1";

  src = fetchurl {
    url = "https://github.com/Embedded-SW-VnV/osdp/releases/download/v1.1.1/osdp-1.1.1.tgz";
    hash = "sha256-X7CS2g+MyQPDjhUCvFS/DoqcCXTEw8SCsSGED64TGKQ=";
  };

  nativeBuildInputs = [
    autoconf
    findlib
    csdp
  ];

  propagatedBuildInputs = [
    zarith
    ocplib-simplex
    csdp
  ];

  preConfigure = ''
    autoconf
  '';

  meta = {
    description = "OCaml Interface to SDP solvers";
    homepage = "https://github.com/Embedded-SW-VnV/osdp";
    license = lib.licenses.lgpl3Plus;
    broken = lib.versionAtLeast ocaml.version "5.0";
  };
}
