{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  haskellPackages,
  makeWrapper,
  pkgsHostTarget,
}:

let
  version = "3.2.3";

  src = fetchFromGitHub {
    owner = "koka-lang";
    repo = "koka";
    tag = "v${version}";
    hash = "sha256-sbyiY5zZuVyul98y5xwfxp7kIzeojdJWxDf6zjWnLrI=";
    fetchSubmodules = true;
  };

  kklib = stdenv.mkDerivation {
    inherit version;
    pname = "kklib";
    src = "${src}/kklib";

    outputs = [
      "out"
      "dev"
    ];

    nativeBuildInputs = [ cmake ];

    postInstall = ''
      mkdir -p ''${!outputDev}/share/koka/v${version}
      cp -a ../../kklib ''${!outputDev}/share/koka/v${version}
    '';
  };

  inherit (pkgsHostTarget.targetPackages.stdenv) cc;
  runtimeDeps = [
    cc
    cc.bintools.bintools
    pkgsHostTarget.gnumake
    pkgsHostTarget.cmake
  ];
in
haskellPackages.mkDerivation {
  inherit version src;
  pname = "koka";
  doCheck = false;

  postInstall = ''
    mkdir -p $out/share/koka/v${version}
    cp -a lib $out/share/koka/v${version}
    ln -s ${kklib.dev}/share/koka/v${version}/kklib $out/share/koka/v${version}
    wrapProgram "$out/bin/koka" \
      --set CC "${lib.getBin cc}/bin/${cc.targetPrefix}cc" \
      --prefix PATH : "${lib.makeSearchPath "bin" runtimeDeps}"
  '';

  buildTools = [ makeWrapper ];
  changelog = "https://github.com/koka-lang/koka/blob/v${version}/doc/spec/news.mdk";
  description = "Koka language compiler and interpreter";
  doHaddock = false;

  executableHaskellDepends = with haskellPackages; [
    FloatingHex
    aeson
    array
    async
    base
    bytestring
    co-log-core
    containers
    directory
    hashable
    isocline
    lens
    lsp_2_8_0_0
    mtl
    network
    network-simple
    parsec
    process
    stm
    text
    text-rope
    time
    kklib
  ];

  executableToolDepends = with haskellPackages; [
    alex
  ];

  homepage = "https://github.com/koka-lang/koka";
  isExecutable = true;
  isLibrary = false;

  libraryToolDepends = with haskellPackages; [
    hpack
  ];

  license = lib.licenses.asl20;

  maintainers = with lib.maintainers; [
    siraben
    sternenseemann
  ];

  prePatch = "hpack";
}
