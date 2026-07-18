{
  lib,
  stdenv,
  fetchurl,
  cmdliner,
  findlib,
  ocaml,
  ocamlbuild,
  topkg,
  uucp,
  uutf,
  cmdlinerSupport ? lib.versionAtLeast cmdliner.version "1.1",
  version ? if lib.versionAtLeast ocaml.version "4.14" then "17.0.0" else "15.0.0",
}:

stdenv.mkDerivation (finalAttrs: {
  inherit version;
  inherit (topkg) installPhase;
  pname = "uuseg";

  src = fetchurl {
    url = "https://erratique.ch/software/uuseg/releases/uuseg-${finalAttrs.version}.tbz";

    hash =
      {
        "15.0.0" = "sha256-q8x3bia1QaKpzrWFxUmLWIraKqby7TuPNGvbSjkY4eM=";
        "17.0.0" = "sha256-Fn41ajEFbMv3LLkD+zqy76217/kWFS7q9jm9ubc6TI4=";
      }
      ."${finalAttrs.version}";
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
  ]
  ++ lib.optional cmdlinerSupport cmdliner;

  propagatedBuildInputs = [ uucp ];

  buildPhase = ''
    runHook preBuild
    ${topkg.run} build \
      --with-uutf true \
      --with-cmdliner ${lib.boolToString cmdlinerSupport}
    runHook postBuild
  '';

  name = "ocaml${ocaml.version}-${finalAttrs.pname}-${finalAttrs.version}";

  meta = {
    inherit (ocaml.meta) platforms;
    description = "OCaml library for segmenting Unicode text";
    homepage = "https://erratique.ch/software/uuseg";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.vbgl ];
    mainProgram = "usegtrip";
  };
})
