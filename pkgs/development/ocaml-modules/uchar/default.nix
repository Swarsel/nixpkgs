{
  lib,
  stdenv,
  fetchurl,
  findlib,
  ocaml,
  ocamlbuild,
  opaline,
  withShared ? true,
}:

stdenv.mkDerivation rec {
  pname = "ocaml${ocaml.version}-uchar";
  version = "0.0.2";

  src = fetchurl {
    url = "https://github.com/ocaml/uchar/releases/download/v${version}/uchar-${version}.tbz";
    sha256 = "1w2saw7zanf9m9ffvz2lvcxvlm118pws2x1wym526xmydhqpyfa7";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    ocamlbuild
    findlib
  ];

  buildPhase = "ocaml pkg/build.ml native=true native-dynlink=${lib.boolToString withShared}";
  installPhase = "${opaline}/bin/opaline -libdir $OCAMLFIND_DESTDIR";
  configurePlatforms = [ ];

  meta = {
    inherit (ocaml.meta) platforms license;
    description = "Compatibility library for OCaml’s Uchar module";
    maintainers = [ lib.maintainers.vbgl ];
  };
}
