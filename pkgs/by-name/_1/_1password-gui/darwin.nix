{
  stdenv,
  meta,
  pname,
  src,
  undmg,
  unzip,
  version,
}:

stdenv.mkDerivation {
  inherit
    pname
    version
    src
    meta
    ;

  nativeBuildInputs = [
    unzip
    undmg
  ];

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  # 1Password is notarized.
  dontFixup = true;
  sourceRoot = ".";
  passthru.updateScript = ./update.sh;
}
