{
  lib,
  stdenv,
  fetchurl,
  curl,
  findlib,
  lwt,
  lwt_ppx,
  ocaml,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "ocurl";
  version = "0.9.2";

  src = fetchurl {
    url = "https://github.com/ygrek/ocurl/releases/download/${version}/ocurl-${version}.tar.gz";
    sha256 = "sha256-4DWXGMh02s1VwLWW5d7h0jtMOUubWmBPGm1hghfWd2M=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    ocaml
    findlib
  ];

  propagatedBuildInputs = [
    curl
    lwt
    lwt_ppx
  ];

  createFindlibDestdir = true;

  meta = {
    description = "OCaml bindings to libcurl (deprecated)";
    homepage = "http://ygrek.org.ua/p/ocurl/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      dandellion
      bennofs
    ];

    platforms = ocaml.meta.platforms or [ ];
    broken = lib.versionOlder ocaml.version "4.04";
  };
}
