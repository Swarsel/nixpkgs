{
  fetchurl,
  meta,
  pname,
  stdenvNoCC,
  undmg,
  version,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit pname version meta;

  src = fetchurl rec {
    url = "https://downloads.realvnc.com/download/file/viewer.files/${name}";
    hash = "sha256-nWS7XsAQFcp2uoXXzT+a542Q9vwloZEQHqf4eieKqUA=";
    name = "VNC-Viewer-${finalAttrs.version}-MacOSX-universal.dmg";
  };

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r *.app $out/Applications

    runHook postInstall
  '';

  sourceRoot = ".";
})
