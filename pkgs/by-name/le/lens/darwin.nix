{
  stdenv,
  meta,
  pname,
  src,
  undmg,
  updateScript,
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

    mkdir -p "$out/Applications"
    cp -R "Lens.app" "$out/Applications/Lens.app"

    runHook postInstall
  '';

  dontFixup = true;
  sourceRoot = ".";
  passthru = { inherit updateScript; };
}
