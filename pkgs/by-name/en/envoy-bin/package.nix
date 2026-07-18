{
  lib,
  fetchurl,
  autoPatchelfHook,
  nixosTests,
  stdenvNoCC,
  versionCheckHook,
}:
let
  version = "1.39.0";
  inherit (stdenvNoCC.hostPlatform) system;
  throwSystem = throw "envoy-bin is not available for ${system}.";

  plat =
    {
      aarch64-linux = "aarch_64";
      x86_64-linux = "x86_64";
    }
    .${system} or throwSystem;

  hash =
    {
      aarch64-linux = "sha256-7lOk9TdVZvFZRNycsDr7H8Io3zj2FzfGd/E5ITIVr88=";
      x86_64-linux = "sha256-RAna3IeTHY+GdjFMvYMHHLZRJftP6sP2M1gAWA36khg=";
    }
    .${system} or throwSystem;
in
stdenvNoCC.mkDerivation {
  inherit version;
  pname = "envoy-bin";

  src = fetchurl {
    inherit hash;
    url = "https://github.com/envoyproxy/envoy/releases/download/v${version}/envoy-${version}-linux-${plat}";
  };

  strictDeps = true;
  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m755 $src $out/bin/envoy

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true;

  passthru = {
    tests.envoy-bin = nixosTests.envoy-bin;
    updateScript = ./update.sh;
  };

  meta = {
    description = "Cloud-native edge and service proxy";
    homepage = "https://envoyproxy.io";
    changelog = "https://github.com/envoyproxy/envoy/releases/tag/v${version}";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];

    maintainers = with lib.maintainers; [
      charludo
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    mainProgram = "envoy";
  };
}
