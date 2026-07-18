{
  meta,
  pname,
  src,
  stdenvNoCC,
  undmg,
  version,
  ...
}:
stdenvNoCC.mkDerivation {
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
    mv Keymapp.app $out/Applications

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  dontPatch = true;
  sourceRoot = ".";
}
