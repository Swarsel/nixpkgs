{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  autoPatchelfHook,
  config,
  curl,
  ffmpeg_4-headless,
  gtk3,
  lame,
  libjack2,
  libpulseaudio,
  libxml2_13,
  makeWrapper,
  openssl,
  undmg,
  vlc,
  which,
  xdg-utils,
  xdotool,
  jackLibrary ? libjack2, # Another option is "pipewire.jack"
  jackSupport ? stdenv.hostPlatform.isLinux,
  pulseaudioSupport ? config.pulseaudio or stdenv.hostPlatform.isLinux,
}:

let
  url_for_platform =
    version: arch:
    if stdenv.hostPlatform.isDarwin then
      "https://www.reaper.fm/files/${lib.versions.major version}.x/reaper${
        builtins.replaceStrings [ "." ] [ "" ] version
      }_universal.dmg"
    else
      "https://www.reaper.fm/files/${lib.versions.major version}.x/reaper${
        builtins.replaceStrings [ "." ] [ "" ] version
      }_linux_${arch}.tar.xz";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "reaper";
  version = "7.76";

  src = fetchurl {
    url = url_for_platform finalAttrs.version stdenv.hostPlatform.qemuArch;

    hash =
      if stdenv.hostPlatform.isDarwin then
        "sha256-7lGMSRXawS8/ISCPLjUlQmxqW/pQy3iWviM+2fZ6LSc="
      else
        {
          aarch64-linux = "sha256-dVloxbTYK3wPSFpIs/UD6ons1ePY7tpTMI7WoSngaVs=";
          x86_64-linux = "sha256-P13PaZjGnA3bLpz9latebVJAdL6ZF+UVtX94mKmq/xg=";
        }
        .${stdenv.hostPlatform.system};
  };

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    which
    autoPatchelfHook
    xdg-utils # Required for install script
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    undmg
  ];

  buildInputs = [
    (lib.getLib stdenv.cc.cc) # reaper and libSwell need libstdc++.so.6
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    gtk3
    alsa-lib
  ];

  installPhase =
    if stdenv.hostPlatform.isDarwin then
      ''
        runHook preInstall
        mkdir -p "$out/Applications/Reaper.app"
        cp -r * "$out/Applications/Reaper.app/"
        makeWrapper "$out/Applications/Reaper.app/Contents/MacOS/REAPER" "$out/bin/reaper"
        runHook postInstall
      ''
    else
      ''
        runHook preInstall

        HOME="$out/share" XDG_DATA_HOME="$out/share" ./install-reaper.sh \
          --install $out/opt \
          --integrate-user-desktop
        rm $out/opt/REAPER/uninstall-reaper.sh

        # Dynamic loading of plugin dependencies does not adhere to rpath of
        # reaper executable that gets modified with runtimeDependencies.
        # Patching each plugin with DT_NEEDED is cumbersome and requires
        # hardcoding of API versions of each dependency.
        # Setting the rpath of the plugin shared object files does not
        # seem to have an effect for some plugins.
        # We opt for wrapping the executable with LD_LIBRARY_PATH prefix.
        # Note that libcurl and libxml2_13 are needed for ReaPack to run.
        wrapProgram $out/opt/REAPER/reaper \
          --prefix PATH : "${lib.makeBinPath [ xdg-utils ]}" \
          --prefix LD_LIBRARY_PATH : "${
            lib.makeLibraryPath [
              curl
              lame
              libxml2_13
              ffmpeg_4-headless
              vlc
              xdotool
              stdenv.cc.cc
              openssl
            ]
          }"

        mkdir $out/bin
        ln -s $out/opt/REAPER/reaper $out/bin/

        # Avoid store path in Exec, since we already link to $out/bin
        substituteInPlace $out/share/applications/cockos-reaper.desktop \
          --replace-fail "Exec=\"$out/opt/REAPER/reaper\"" "Exec=reaper"

        runHook postInstall
      '';

  dontBuild = true;
  dontStrip = true;

  runtimeDependencies =
    lib.optionals stdenv.hostPlatform.isLinux [
      gtk3 # libSwell needs libgdk-3.so.0
    ]
    ++ lib.optional jackSupport jackLibrary
    ++ lib.optional pulseaudioSupport libpulseaudio;

  sourceRoot = lib.optionalString stdenv.hostPlatform.isDarwin "Reaper.app";
  passthru.updateScript = ./updater.sh;

  meta = {
    description = "Digital audio workstation";
    homepage = "https://www.reaper.fm/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      ilian
      viraptor
      pancaek
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
})
