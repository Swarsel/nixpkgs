{
  lib,
  stdenv,
  fetchurl,
  nix-update-script,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "apfel-llm";
  version = "1.8.3";

  # Building from source requires swift 6.3.0 while nixpkgs only has 5.10.1
  src = fetchurl {
    url = "https://github.com/Arthur-Ficial/apfel/releases/download/v${finalAttrs.version}/apfel-${finalAttrs.version}-arm64-macos.tar.gz";
    hash = "sha256-1AA86f5+Poo5YCrtxT1rAPGBctQbNa5hdAZmI008/yU=";
  };

  strictDeps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp apfel $out/bin/
    chmod +x $out/bin/apfel

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  dontBuild = true;
  dontConfigure = true;
  sourceRoot = ".";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Local Apple Intelligence LLM CLI and server";
    homepage = "https://github.com/Arthur-Ficial/apfel";
    changelog = "https://github.com/Arthur-Ficial/apfel/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    sourceProvenance = [
      lib.sourceTypes.binaryNativeCode
    ];

    maintainers = with lib.maintainers; [ arthurficial ];
    platforms = [ "aarch64-darwin" ];
    mainProgram = "apfel";
  };
})
