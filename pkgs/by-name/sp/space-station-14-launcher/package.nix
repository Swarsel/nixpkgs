{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  buildDotnetModule,
  config,
  copyDesktopItems,
  dbus,
  dotnetCorePackages,
  fontconfig,
  freetype,
  glib,
  iconConvTools,
  libGL,
  libice,
  libjack2,
  libpulseaudio,
  libsm,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxkbcommon,
  libxrandr,
  makeDesktopItem,
  nix-update-script,
  pipewire,
  soundfont-fluid,
  wayland,
  alsaSupport ? stdenv.hostPlatform.isLinux,
  jackSupport ? stdenv.hostPlatform.isLinux,
  pipewireSupport ? stdenv.hostPlatform.isLinux,
  pulseaudioSupport ? config.pulseaudio or stdenv.hostPlatform.isLinux,
  # Path to set ROBUST_SOUNDFONT_OVERRIDE to, essentially the default soundfont used.
  soundfont-path ? "${soundfont-fluid}/share/soundfonts/FluidR3_GM2-2.sf2",
}:
let
  pname = "space-station-14-launcher";
  version = "0.39.1";
in
buildDotnetModule rec {
  inherit pname;

  src = fetchFromGitHub {
    owner = "space-wizards";
    repo = "SS14.Launcher";
    tag = "v${version}";
    hash = "sha256-u3tsPWAFMckWSHhiPqL50i9BMxR+VrLnpUSWGRRu9AA=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    iconConvTools
    copyDesktopItems
  ];

  postInstall = ''
    mkdir -p $out/lib/space-station-14-launcher/loader
    cp -r SS14.Loader/bin/${buildType}/*/*/* $out/lib/space-station-14-launcher/loader/

    icoFileToHiColorTheme SS14.Launcher/Assets/icon.ico ${pname} $out
  '';

  buildType = "Release";

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = meta.description;
      desktopName = "Space Station 14 Launcher";
      exec = meta.mainProgram;
      icon = pname;
      name = pname;
      startupWMClass = meta.mainProgram;
    })
  ];

  dotnet-runtime = dotnetCorePackages.runtime_10_0;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;

  dotnetFlags = [
    "-p:FullRelease=true"
    "-p:RobustILLink=true"
    "-nologo"
  ];

  executables = [ "SS14.Launcher" ];
  # ${soundfont-path} is escaped here:
  # https://github.com/NixOS/nixpkgs/blob/d29975d32b1dc7fe91d5cb275d20f8f8aba399ad/pkgs/build-support/setup-hooks/make-wrapper.sh#L126C35-L126C45
  # via https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html under ${parameter@operator}
  makeWrapperArgs = [ "--set ROBUST_SOUNDFONT_OVERRIDE ${soundfont-path}" ];
  # Workaround to prevent buildDotnetModule from overriding assembly versions.
  # If you inherit version it will break loading Robust.LoaderApi when connecting to a server!
  name = "${pname}-${version}";
  nugetDeps = ./deps.json;

  projectFile = [
    "SS14.Loader/SS14.Loader.csproj"
    "SS14.Launcher/SS14.Launcher.csproj"
  ];

  runtimeDeps = [
    libGL
    freetype
    glib
    libx11
    libice
    libsm
    libxi
    libxcursor
    libxext
    libxrandr
    at-spi2-atk
    at-spi2-core
    libxkbcommon
    wayland
    fontconfig.lib
    dbus
  ]
  ++ lib.optional alsaSupport alsa-lib
  ++ lib.optional jackSupport libjack2
  ++ lib.optional pipewireSupport pipewire
  ++ lib.optional pulseaudioSupport libpulseaudio;

  selfContainedBuild = false;

  passthru = {
    inherit version;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Launcher for Space Station 14, a multiplayer game about paranoia and disaster";
    homepage = "https://spacestation14.io";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.coca ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "SS14.Launcher";
  };
}
