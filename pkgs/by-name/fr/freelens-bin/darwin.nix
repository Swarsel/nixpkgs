{
  _7zz,
  autoSignDarwinBinariesHook,
  meta,
  passthru,
  pname,
  src,
  stdenvNoCC,
  version,
}:

stdenvNoCC.mkDerivation {
  inherit
    pname
    version
    src
    passthru
    meta
    ;

  # APFS format is unsupported by undmg
  nativeBuildInputs = [
    _7zz
    autoSignDarwinBinariesHook
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    cp -R Freelens*/Freelens.app "$out/Applications/Freelens.app"

    runHook postInstall
  '';

  sourceRoot = ".";
}
