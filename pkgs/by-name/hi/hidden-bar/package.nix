{
  lib,
  fetchurl,
  stdenvNoCC,
  unzip,
}:

stdenvNoCC.mkDerivation rec {
  pname = "hidden-bar";
  version = "1.10";

  src = fetchurl {
    url = "https://github.com/dwarvesf/hidden/releases/download/v${version}/Hidden-Bar-v${version}-macos.zip";
    hash = "sha256-qKX1KZ/fq1K9/7L1cop21MumkHVOmzsS8nvTjy52wLw=";
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    mv "Hidden Bar.app" $out/Applications

    runHook postInstall
  '';

  sourceRoot = ".";

  meta = {
    description = "Ultra-light MacOS utility that helps hide menu bar icons";
    homepage = "https://github.com/dwarvesf/hidden";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ _4evy ];
    platforms = lib.platforms.darwin;
  };
}
