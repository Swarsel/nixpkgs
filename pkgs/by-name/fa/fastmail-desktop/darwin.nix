{
  meta,
  passthru,
  pname,
  src,
  stdenvNoCC,
  unzip,
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

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/Applications
    cp -R Fastmail.app $out/Applications/
  '';

  dontBuild = true;
  # Fastmail is notarized
  dontFixup = true;
  sourceRoot = ".";
}
