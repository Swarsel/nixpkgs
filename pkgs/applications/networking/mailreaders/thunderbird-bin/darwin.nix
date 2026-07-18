{
  stdenv,
  meta,
  nativeBuildInputs,
  passthru,
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
    ;

  inherit passthru meta;
  nativeBuildInputs = nativeBuildInputs ++ [ undmg ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    mv Thunderbird*.app "$out/Applications/${passthru.applicationName}.app"

    runHook postInstall
  '';

  # don't break code signing
  dontFixup = true;
  sourceRoot = ".";
}
