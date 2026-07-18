{
  lib,
  stdenv,
  fetchurl,
  cmdliner,
  findlib,
  ocaml,
  ocamlbuild,
  topkg,
  uutf,
  cmdlinerSupport ? lib.versionAtLeast cmdliner.version "1.1",
  version ? if lib.versionAtLeast ocaml.version "4.14" then "17.0.0" else "15.0.0",
}:

let
  pname = "uunf";
  webpage = "https://erratique.ch/software/${pname}";
  hash =
    {
      "15.0.0" = "sha256-B/prPAwfqS8ZPS3fyDDIzXWRbKofwOCyCfwvh9veuug=";
      "17.0.0" = "sha256-5XYZU8Ros2aiCy04xzLiwhN+v5kM9Y3twdVPQ8IY1GA=";
    }
    ."${version}";
in
stdenv.mkDerivation (finallAttrs: {
  inherit version pname;
  inherit (topkg) installPhase;

  src = fetchurl {
    inherit hash;
    url = "${webpage}/releases/${pname}-${version}.tbz";
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

  buildPhase = ''
    runHook preBuild
    ${topkg.run} build \
      --with-uutf true \
      --with-cmdliner ${lib.boolToString cmdlinerSupport}
    runHook postBuild
  '';

  name = "ocaml${ocaml.version}-${finallAttrs.pname}-${finallAttrs.version}";
  prePatch = lib.optionalString stdenv.hostPlatform.isAarch64 "ulimit -s 16384";

  meta = {
    inherit (ocaml.meta) platforms;
    description = "OCaml module for normalizing Unicode text";
    homepage = webpage;
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.vbgl ];
    mainProgram = "unftrip";
    broken = lib.versionOlder ocaml.version "4.03";
  };
})
