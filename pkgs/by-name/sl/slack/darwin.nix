{
  meta,
  passthru,
  pname,
  src,
  stdenvNoCC,
  undmg,
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

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -a Slack.app $out/Applications
    runHook postInstall
  '';

  sourceRoot = ".";
}
