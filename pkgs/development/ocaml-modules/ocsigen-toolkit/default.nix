{
  lib,
  stdenv,
  fetchFromGitHub,
  calendar,
  eliom,
  findlib,
  js_of_ocaml-ppx_deriving_json,
  ocaml,
  opaline,
}:

stdenv.mkDerivation rec {
  pname = "ocsigen-toolkit";
  version = "4.2.0";

  src = fetchFromGitHub {
    owner = "ocsigen";
    repo = "ocsigen-toolkit";
    tag = version;
    hash = "sha256-wken+5hUewE0Nktl2PY1xMmVveSs8X0ihWD+MK4pzRQ=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    opaline
    eliom
  ];

  propagatedBuildInputs = [
    calendar
    js_of_ocaml-ppx_deriving_json
    eliom
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $OCAMLFIND_DESTDIR
    export OCAMLPATH=$out/lib/ocaml/${ocaml.version}/site-lib/:$OCAMLPATH
    make install
    opaline -prefix $out
    runHook postInstall
  '';

  name = "ocaml${ocaml.version}-${pname}-${version}";

  meta = {
    inherit (ocaml.meta) platforms;
    description = "User interface widgets for Ocsigen applications";
    homepage = "http://ocsigen.org/ocsigen-toolkit/";
    license = lib.licenses.lgpl21;
    maintainers = [ lib.maintainers.gal_bolle ];
    broken = true;
  };

}
