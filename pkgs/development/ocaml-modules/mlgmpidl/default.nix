{
  lib,
  stdenv,
  fetchFromGitHub,
  bigarray-compat,
  camlidl,
  findlib,
  gmp,
  mpfr,
  ocaml,
  perl,
}:

stdenv.mkDerivation rec {
  pname = "ocaml${ocaml.version}-mlgmpidl";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "nberth";
    repo = "mlgmpidl";
    rev = version;
    hash = "sha256-ZmSDKZiHko8MCeIuZL53HjupfwO6PAm8QOCc9O3xJOk=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    perl
    ocaml
    findlib
    camlidl
  ];

  buildInputs = [
    gmp
    mpfr
  ];

  propagatedBuildInputs = [ bigarray-compat ];

  postConfigure = ''
    mkdir -p $out/lib/ocaml/${ocaml.version}/site-lib/stublibs
  '';

  prefixKey = "-prefix ";

  meta = {
    inherit (ocaml.meta) platforms;
    description = "OCaml interface to the GMP library";
    homepage = "https://www.inrialpes.fr/pop-art/people/bjeannet/mlxxxidl-forge/mlgmpidl/";
    license = lib.licenses.lgpl21;
    maintainers = [ lib.maintainers.vbgl ];
  };
}
