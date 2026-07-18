{
  lib,
  fetchurl,
  installShellFiles,
  platformsh,
  stdenvNoCC,
  testers,
}:

let
  versions = lib.importJSON ./versions.json;
  arch =
    if stdenvNoCC.hostPlatform.isx86_64 then
      "amd64"
    else if stdenvNoCC.hostPlatform.isAarch64 then
      "arm64"
    else
      throw "Unsupported architecture";
  os =
    if stdenvNoCC.hostPlatform.isLinux then
      "linux"
    else if stdenvNoCC.hostPlatform.isDarwin then
      "darwin"
    else
      throw "Unsupported os";
  versionInfo = versions."${os}-${arch}";
  inherit (versionInfo) hash url;

in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (versions) version;
  pname = "platformsh";
  # run ./update
  src = fetchurl { inherit hash url; };
  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall

    install -Dm755 platform $out/bin/platform

    installShellCompletion completion/bash/platform.bash \
        completion/zsh/_platform

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  sourceRoot = ".";

  passthru = {
    tests.version = testers.testVersion {
      inherit (finalAttrs) version;
      package = platformsh;
    };

    updateScript = ./update.sh;
  };

  meta = {
    description = "Unified tool for managing your Platform.sh services from the command line";
    homepage = "https://github.com/platformsh/cli";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      spk
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "platform";
  };
})
