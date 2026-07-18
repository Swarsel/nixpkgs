{
  lib,
  stdenv,
  fetchurl,
  augeas,
  autoreconfHook,
  fetchpatch,
  findlib,
  libxml2,
  makeWrapper,
  ocaml,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "ocaml-augeas";
  version = "0.6";

  src = fetchurl {
    url = "https://people.redhat.com/~rjones/augeas/files/ocaml-augeas-0.6.tar.gz";
    sha256 = "04bn62hqdka0658fgz0p0fil2fyic61i78plxvmni1yhmkfrkfla";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-EMd/EfWO2ni0AMonfS7G5FENpVVq0+q3gUPd4My+Upg=";
      url = "https://salsa.debian.org/debian/ocaml-augeas/-/raw/07c2408a7e5a06cefe5d53a89fecaa8556a39b06/debian/patches/0001-Use-ocamlopt-g-option.patch";
    })
    (fetchpatch {
      hash = "sha256-Y53UHwrTVeV3hnsvABmWxlPi2Fanm0Iy1OR8Zql5Ub8=";
      url = "https://salsa.debian.org/debian/ocaml-augeas/-/raw/07c2408a7e5a06cefe5d53a89fecaa8556a39b06/debian/patches/0002-caml_named_value-returns-const-value-pointer-in-OCam.patch";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    ocaml
    findlib
    augeas
    libxml2
  ];

  createFindlibDestdir = true;

  meta = {
    description = "OCaml bindings for Augeas";
    homepage = "https://people.redhat.com/~rjones/augeas/";
    license = with lib.licenses; lgpl21Plus;
    platforms = with lib.platforms; linux;
  };
}
