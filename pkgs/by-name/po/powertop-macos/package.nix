{
  lib,
  fetchurl,
  makeWrapper,
  nix-update-script,
  rcodesign,
  stdenvNoCC,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "powertop-macos";
  version = "1.3.3";

  src = fetchurl {
    url = "https://github.com/kDolphin/PowerTop/releases/download/v${finalAttrs.version}/PowerTop.zip";
    hash = "sha256-GIuhJVyKjFsltlg9zZByHryaIYV6F+5Uj1yTucOL9Gw=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
    rcodesign
    unzip
  ];

  installPhase = ''
    runHook preInstall

    app="$out/Applications/PowerTop.app"
    mkdir -p "$out/Applications"
    cp -R PowerTop.app "$app"

    makeWrapper "$app/Contents/MacOS/PowerTop" "$out/bin/powertop-macos"

    runHook postInstall
  '';

  postFixup = ''
    ${lib.getExe rcodesign} sign "$out/Applications/PowerTop.app"
  '';

  __structuredAttrs = true;
  dontBuild = true;
  dontConfigure = true;
  sourceRoot = ".";
  passthru.updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };

  meta = {
    description = "Menu bar app for monitoring MacBook power usage";
    homepage = "https://github.com/kDolphin/PowerTop";
    changelog = "https://github.com/kDolphin/PowerTop/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    platforms = [ "aarch64-darwin" ];
    mainProgram = "powertop-macos";
  };
})
