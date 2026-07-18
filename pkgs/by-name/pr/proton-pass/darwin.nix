{
  stdenv,
  meta,
  passthru,
  pname,
  undmg,
  version,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit
    pname
    version
    passthru
    meta
    ;

  src = passthru.sources.${stdenv.hostPlatform.system};
  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r *.app $out/Applications

    runHook postInstall
  '';

  sourceRoot = ".";
})
