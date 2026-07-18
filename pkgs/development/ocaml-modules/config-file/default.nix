{
  lib,
  stdenv,
  fetchurl,
  camlp4,
  findlib,
  ocaml,
}:

stdenv.mkDerivation rec {
  pname = "ocaml-config-file";
  version = "1.2";

  src = fetchurl {
    url = "https://forge.ocamlcore.org/frs/download.php/1387/config-file-${version}.tar.gz";
    sha256 = "1b02yxcnsjhr05ssh2br2ka4hxsjpdw34ldl3nk33wfnkwk7g67q";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    camlp4
  ];

  createFindlibDestdir = true;

  meta = {
    description = "OCaml library used to manage the configuration file(s) of an application";
    homepage = "http://config-file.forge.ocamlcore.org/";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ vbgl ];
    platforms = ocaml.meta.platforms or [ ];
    broken = lib.versionAtLeast ocaml.version "5.0";
  };
}
