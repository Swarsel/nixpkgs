{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  nix-update-script,
}:

buildDotnetModule (finalAttrs: {
  pname = "hedgemodmanager";
  version = "8.0.0-beta4";

  src = fetchFromGitHub {
    owner = "hedge-dev";
    repo = "HedgeModManager";
    tag = finalAttrs.version;
    hash = "sha256-1uwcpeyOxwKI0fyAmchYEMqStF52wXkCZej+ZQ+aFeY=";
  };

  postPatch = ''
    substituteInPlace flatpak/hedgemodmanager.desktop --replace-fail "/app/bin/HedgeModManager.UI" "HedgeModManager.UI"
  '';

  # https://github.com/hedge-dev/HedgeModManager/blob/8.0.0-beta4/flatpak/io.github.hedge_dev.hedgemodmanager.yml#L53-L55
  postInstall = ''
    install -Dm644 flatpak/hedgemodmanager.png $out/share/icons/hicolor/256x256/apps/io.github.hedge_dev.hedgemodmanager.png
    install -Dm644 flatpak/hedgemodmanager.metainfo.xml $out/share/metainfo/io.github.hedge_dev.hedgemodmanager.metainfo.xml
    install -Dm644 flatpak/hedgemodmanager.desktop $out/share/applications/io.github.hedge_dev.hedgemodmanager.desktop
  '';

  dotnet-runtime = dotnetCorePackages.runtime_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  nugetDeps = ./deps.json;
  projectFile = "Source/HedgeModManager.UI/HedgeModManager.UI.csproj";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "unstable"
    ];
  };

  meta = {
    description = "Mod manager for Hedgehog Engine games";
    homepage = "https://github.com/hedge-dev/HedgeModManager";
    changelog = "https://github.com/hedge-dev/HedgeModManager/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "HedgeModManager.UI";
  };
})
