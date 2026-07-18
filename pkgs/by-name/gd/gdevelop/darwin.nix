{
  fetchurl,
  meta,
  passthru,
  pname,
  stdenvNoCC,
  unzip,
  version,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit
    pname
    version
    meta
    passthru
    ;

  src = fetchurl {
    url = "https://github.com/4ian/GDevelop/releases/download/v${version}/GDevelop-5-${version}-universal-mac.zip";
    hash = "sha256-B/QyB6ZdyjIBBOOZG1nnVcXyqbPGyf56AndELzi3IZY=";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -r "GDevelop 5.app" $out/Applications/
    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;
  dontPatch = true;
  sourceRoot = ".";

})
