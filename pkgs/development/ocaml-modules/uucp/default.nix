{
  lib,
  stdenv,
  fetchurl,
  findlib,
  ocaml,
  ocamlbuild,
  topkg,
  uchar,
  uucd,
  uunf,
  uutf,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (topkg) installPhase;
  pname = "uucp";
  version = "17.0.0";

  src = fetchurl {
    url = "https://erratique.ch/software/uucp/releases/uucp-${finalAttrs.version}.tbz";
    hash = "sha256-mSQtTn4DYa15pYWFt0J+/BEpJRaa+6uIKnifMV4Euhs=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    ocamlbuild
    topkg
  ];

  buildInputs = [
    topkg
    uutf
    uunf
    uucd
  ];

  propagatedBuildInputs = [ uchar ];

  buildPhase = ''
    runHook preBuild
    ${topkg.buildPhase} --with-cmdliner false --tests ${lib.boolToString finalAttrs.doCheck}
    runHook postBuild
  '';

  doCheck = true;
  checkInputs = [ uucd ];

  checkPhase = ''
    runHook preCheck
    ${topkg.run} test
    runHook postCheck
  '';

  name = "ocaml${ocaml.version}-${finalAttrs.pname}-${finalAttrs.version}";

  meta = {
    inherit (ocaml.meta) platforms;
    description = "OCaml library providing efficient access to a selection of character properties of the Unicode character database";
    homepage = "https://erratique.ch/software/uucp";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
