{
  lib,
  fetchurl,
  autoPatchelfHook,
  stdenvNoCC,
  versionCheckHook,
}:
let
  version = "1.0.12";
  buildId = "6156052174077952";
  wholeVersion = "${version}-${buildId}";

  throwSystem = throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}";

  sourceData = {
    aarch64-darwin = fetchurl {
      hash = "sha256-U/cwihF/cP5+7KSmkAToI5yOoYydguR5ZrKQMytpuCk=";
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/${wholeVersion}/darwin-arm/cli_mac_arm64.tar.gz";
    };

    aarch64-linux = fetchurl {
      hash = "sha256-oDZ+WHWsG4imwLFjyG69XRPJvvkH9EaaZRb/aQIb8tQ=";
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/${wholeVersion}/linux-arm/cli_linux_arm64.tar.gz";
    };

    x86_64-linux = fetchurl {
      hash = "sha256-fjB132jrrViqHPQiMenYuDvyiVtbBYqxc2sLY4PHUAg=";
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/${wholeVersion}/linux-x64/cli_linux_x64.tar.gz";
    };
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit version;
  pname = "antigravity-cli";
  src = sourceData.${stdenvNoCC.hostPlatform.system} or throwSystem;
  strictDeps = true;
  nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isElf [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall

    install -Dm755 antigravity $out/bin/agy

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  dontBuild = true;
  dontConfigure = true;
  sourceRoot = ".";

  passthru = {
    inherit wholeVersion; # for the updateScript
    updateScript = ./update.sh;
  };

  meta = {
    description = "Google's Go-based terminal user interface (TUI) agent client";
    homepage = "https://antigravity.google";
    changelog = "https://antigravity.google/changelog";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      adrielvelazquez
      u3kkasha
    ];

    platforms = lib.attrNames sourceData;
    mainProgram = "agy";
  };
})
