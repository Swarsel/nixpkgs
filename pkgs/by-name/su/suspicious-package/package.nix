{
  lib,
  stdenv,
  fetchurl,
  undmg,
  versionCheckHook,
}:

let
  snapshot = "20250820185748";
in
stdenv.mkDerivation {
  pname = "suspicious-package";
  version = "4.6";

  src = fetchurl {
    # Use externally archived download URL because
    # upstream does not provide stable URLs for versioned releases
    url = "https://web.archive.org/web/${snapshot}/https://www.mothersruin.com/software/downloads/SuspiciousPackage.dmg";
    hash = "sha256-SJcXqQR/di3T8K3uNKv00QkLsmDGJNU9NQEIpDSqYJM=";
  };

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications/Suspicious Package.app" $out/bin
    cp -R . "$out/Applications/Suspicious Package.app"
    ln -s "../Applications/Suspicious Package.app/Contents/SharedSupport/spkg" $out/bin

    runHook postInstall
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  sourceRoot = "Suspicious Package.app";

  meta = {
    description = "Toolkit for analysing macOS packages";
    homepage = "https://www.mothersruin.com/software/SuspiciousPackage/";
    license = lib.licenses.unfreeRedistributable;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ andre4ik3 ];
    platforms = lib.platforms.darwin;
    mainProgram = "spkg";
  };
}
