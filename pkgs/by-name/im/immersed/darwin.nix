{
  stdenv,
  meta,
  pname,
  src,
  undmg,
  version,
}:

stdenv.mkDerivation {
  inherit
    pname
    version
    src
    meta
    ;

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r *.app $out/Applications

    runHook postInstall
  '';

  # Immersed is notarized.
  dontFixup = true;
  sourceRoot = ".";
}
