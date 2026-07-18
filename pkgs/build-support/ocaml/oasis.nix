{
  lib,
  stdenv,
  findlib,
  ocaml,
  ocaml_oasis,
  ocamlbuild,
}:

{
  pname,
  version,
  createFindlibDestdir ? true,
  dontStrip ? true,
  meta ? {
    platforms = ocaml.meta.platforms or [ ];
  },
  minimumOCamlVersion ? null,
  nativeBuildInputs ? [ ],
  ...
}@args:

stdenv.mkDerivation (
  args
  // {
    inherit createFindlibDestdir;
    inherit dontStrip;
    strictDeps = true;

    nativeBuildInputs = [
      ocaml
      findlib
      ocamlbuild
      ocaml_oasis
    ]
    ++ nativeBuildInputs;

    buildPhase = ''
      runHook preBuild
      oasis setup
      ocaml setup.ml -configure --prefix $OCAMLFIND_DESTDIR --exec-prefix $out
      ocaml setup.ml -build
      runHook postBuild
    '';

    checkPhase = ''
      runHook preCheck
      ocaml setup.ml -test
      runHook postCheck
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      ocaml setup.ml -install
      runHook postInstall
    '';

    name = "ocaml${ocaml.version}-${pname}-${version}";

    meta = args.meta // {
      broken = args ? minimumOCamlVersion && lib.versionOlder ocaml.version args.minimumOCamlVersion;
    };
  }
)
