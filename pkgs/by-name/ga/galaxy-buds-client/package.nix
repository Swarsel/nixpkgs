{
  lib,
  stdenv,
  fetchFromGitHub,
  buildDotnetModule,
  copyDesktopItems,
  dotnetCorePackages,
  fontconfig,
  glib,
  libglvnd,
  libxinerama,
  libxkbcommon,
  libxt,
  libxtst,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
}:

buildDotnetModule rec {
  pname = "galaxy-buds-client";
  version = "5.2.1";

  src = fetchFromGitHub {
    owner = "timschneeb";
    repo = "GalaxyBudsClient";
    tag = version;
    hash = "sha256-jPVrSkf6Bybwc5glkxId5VeWkwLBoTjOzM3CCgO6h9I=";
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    fontconfig
  ];

  postFixup = ''
    wrapProgram "$out/bin/GalaxyBudsClient" \
      --prefix PATH : ${glib.bin}/bin

    mkdir -p $out/share/icons/hicolor/256x256/apps/
    cp -r $src/GalaxyBudsClient/Resources/icon.png $out/share/icons/hicolor/256x256/apps/${meta.mainProgram}.png

    # remove wrongly created wrapper for shared objects
    rm $out/bin/*.so
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Settings" ];
      comment = meta.description;
      desktopName = meta.mainProgram;
      exec = meta.mainProgram;
      genericName = "Galaxy Buds Client";
      icon = meta.mainProgram;
      name = meta.mainProgram;
      startupNotify = true;
      type = "Application";
    })
  ];

  dotnet-runtime = dotnetCorePackages.runtime_10_0;
  dotnet-sdk = dotnetCorePackages.sdk_10_0_1xx;

  dotnetFlags =
    lib.optionals stdenv.hostPlatform.isx86_64 [ "-p:Runtimeidentifier=linux-x64" ]
    ++ lib.optionals stdenv.hostPlatform.isAarch64 [ "-p:Runtimeidentifier=linux-arm64" ];

  nugetDeps = ./deps.json;
  projectFile = [ "GalaxyBudsClient/GalaxyBudsClient.csproj" ];

  runtimeDeps = [
    libglvnd
    libxinerama
    libxkbcommon
    libxt
    libxtst
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Unofficial Galaxy Buds Manager";
    homepage = "https://github.com/timschneeb/GalaxyBudsClient";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ icy-thought ];
    platforms = lib.platforms.linux;
    mainProgram = "GalaxyBudsClient";
  };
}
