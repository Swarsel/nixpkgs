{
  lib,
  stdenv,
  fetchurl,
  camlzip,
  findlib,
  gnutls,
  ncurses,
  nettle,
  ocaml,
  ocaml_pcre,
  pkg-config,
  which,
}:

stdenv.mkDerivation rec {
  pname = "ocaml${ocaml.version}-ocamlnet";
  version = "4.1.9";

  src = fetchurl {
    url = "http://download.camlcity.org/download/ocamlnet-${version}.tar.gz";
    sha256 = "1vlwxjxr946gdl61a1d7yk859cijq45f60dhn54ik3w4g6cx33pr";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    which
    ocaml
    findlib
  ];

  buildInputs = [
    ncurses
    ocaml_pcre
    camlzip
    gnutls
    nettle
  ];

  preConfigure = ''
    configureFlagsArray=(
      -bindir $out/bin
      -enable-gnutls
      -enable-zip
      -enable-pcre
      -disable-gtk2
      -with-nethttpd
      -datadir $out/lib/ocaml/${ocaml.version}/ocamlnet
    )
  '';

  buildPhase = ''
    make all
    make opt
  '';

  configurePlatforms = [ ];
  createFindlibDestdir = true;
  dontAddPrefix = true;
  dontAddStaticConfigureFlags = true;

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Library implementing Internet protocols (http, cgi, email, etc.) for OCaml";
    homepage = "http://projects.camlcity.org/projects/ocamlnet.html";

    license =
      with lib.licenses;
      AND [
        mit
        bsd3
        gpl2Only
      ];

    broken = lib.versionOlder ocaml.version "4.02" || lib.versionAtLeast ocaml.version "5.0";
  };
}
