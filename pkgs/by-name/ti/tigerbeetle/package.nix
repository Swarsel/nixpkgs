{
  lib,
  fetchzip,
  nix-update-script,
  stdenvNoCC,
  testers,
  tigerbeetle,
}:
let
  platform =
    if stdenvNoCC.hostPlatform.isDarwin then "universal-macos" else stdenvNoCC.hostPlatform.system;
  hash = builtins.getAttr platform {
    "aarch64-linux" = "sha256-4mSFOvgoz7d14iKWl6B6jYwkEz1Yud8Apt9yT/E7ynY=";
    "universal-macos" = "sha256-kvTRqAZ1kX9ojZdto5sRxPm/sUU8dRGb31GKszr5KTo=";
    "x86_64-linux" = "sha256-fuNmpCZ/0cV+AuOLeG5RvBxFd/hGYrx005QJWCihPpY=";
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "tigerbeetle";
  version = "0.17.9";

  src = fetchzip {
    inherit hash;
    url = "https://github.com/tigerbeetle/tigerbeetle/releases/download/${finalAttrs.version}/tigerbeetle-${platform}.zip";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp $src/tigerbeetle $out/bin/tigerbeetle

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true;

  passthru = {
    tests.version = testers.testVersion {
      command = "tigerbeetle version";
      package = tigerbeetle;
    };

    updateScript = ./update.sh;
  };

  meta = {
    description = "Financial accounting database designed to be distributed and fast";
    homepage = "https://tigerbeetle.com/";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];

    maintainers = with lib.maintainers; [
      danielsidhion
      nwjsmith
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ]
    ++ lib.platforms.darwin;

    mainProgram = "tigerbeetle";
  };
})
