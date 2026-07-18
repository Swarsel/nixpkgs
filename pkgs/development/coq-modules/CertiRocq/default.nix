{
  lib,
  ExtLib,
  compcert,
  coq,
  metarocq-erasure-plugin,
  metarocq-safechecker-plugin,
  mkCoqDerivation,
  pkg-config,
  pkgs,
  wasmcert,
  version ? null,
}:

with lib;
mkCoqDerivation {
  inherit version;
  pname = "CertiRocq";

  buildInputs = [
    pkgs.clang
  ];

  propagatedBuildInputs = [
    wasmcert
    compcert
    ExtLib
    metarocq-erasure-plugin
    metarocq-safechecker-plugin
  ];

  buildPhase = ''
    runHook preBuild

    make all
    make plugins

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    OUTDIR=$out/lib/coq/${coq.coq-version}/user-contrib

    DST=$OUTDIR/CertiRocq/Plugin/runtime make -C runtime install
    COQLIBINSTALL=$OUTDIR make -C theories install
    COQLIBINSTALL=$OUTDIR make -C libraries install
    COQLIBINSTALL=$OUTDIR COQPLUGININSTALL=$OCAMLFIND_DESTDIR make -C plugin install
    COQLIBINSTALL=$OUTDIR COQPLUGININSTALL=$OCAMLFIND_DESTDIR make -C cplugin install

    runHook postInstall
  '';

  configurePhase = ''
    ./configure.sh local
  '';

  defaultVersion =
    let
      case = coq: mr: out: {
        inherit out;

        cases = [
          coq
          mr
        ];
      };
    in
    lib.switch
      [
        coq.coq-version
        metarocq-erasure-plugin.version
      ]
      [
        (case "9.1" "1.5.1-9.1" "0.9.1+9.1")
      ]
      null;

  mlPlugin = true;
  opam-name = "rocq-certirocq";
  owner = "CertiRocq";

  patchPhase = ''
    patchShebangs ./configure.sh
    patchShebangs ./clean_extraction.sh
    patchShebangs ./make_plugin.sh
  '';

  release = {
    "0.9.1+9.1".hash = "sha256-YsweBaoq8+QG63e7Llp/4bHldAFnSQSyMumJkb+Bsp0=";
  };

  releaseRev = v: "v${v}";
  repo = "certirocq";

  meta = {
    description = "CertiRocq";
    license = licenses.mit;

    maintainers = with maintainers; [
      womeier
      _4ever2
    ];
  };
}
