{
  lib,
  stdenv,
  haskellPackages,
  makeWrapper,
  packages ? (pkgs: [ ]),
}:

let
  defaultPkgs = pkgs: [
    pkgs.show
    pkgs.simple-reflect
    pkgs.QuickCheck
    pkgs.mtl
  ];
  env = haskellPackages.ghcWithPackages (pkgs: defaultPkgs pkgs ++ packages pkgs);

in
stdenv.mkDerivation {
  inherit (haskellPackages.mueval) version;
  inherit (haskellPackages) mueval;
  pname = "mueval";
  nativeBuildInputs = [ makeWrapper ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/bin

    makeWrapper $mueval/bin/mueval $out/bin/mueval \
      --set "NIX_GHC_LIBDIR" "$(${lib.getExe' env "ghc"} --print-libdir)"

    runHook postBuild
  '';

  dontUnpack = true;
  passthru = { inherit defaultPkgs; };
  meta.mainProgram = "mueval";
}
