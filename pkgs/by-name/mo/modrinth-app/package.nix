{
  lib,
  stdenv,
  addDriverRunpath,
  alsa-lib,
  flite,
  glib,
  glib-networking,
  gsettings-desktop-schemas,
  jdk17,
  jdk21,
  jdk25,
  jdk8,
  libGL,
  libjack2,
  libpulseaudio,
  libx11,
  libxcursor,
  libxext,
  libxrandr,
  libxxf86vm,
  modrinth-app-unwrapped,
  pipewire,
  symlinkJoin,
  udev,
  wrapGAppsHook3,
  xrandr,
  jdks ? [
    jdk8
    jdk17
    jdk21
    jdk25
  ],
}:

symlinkJoin {
  inherit (modrinth-app-unwrapped) version;
  pname = "modrinth-app";
  strictDeps = true;

  nativeBuildInputs = [
    glib
    wrapGAppsHook3
  ];

  buildInputs = [
    glib-networking
    gsettings-desktop-schemas
  ];

  postBuild = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${lib.makeSearchPath "bin/java" jdks}
      ${lib.optionalString stdenv.hostPlatform.isLinux ''
        --prefix PATH : ${lib.makeBinPath [ xrandr ]}
        --set LD_LIBRARY_PATH $runtimeDependencies
      ''}
    )

    glibPostInstallHook
    gappsWrapperArgsHook
    wrapGAppsHook
  '';

  paths = [ modrinth-app-unwrapped ];

  runtimeDependencies = lib.optionalString stdenv.hostPlatform.isLinux (
    lib.makeLibraryPath [
      addDriverRunpath.driverLink

      # glfw
      libGL
      libx11
      libxcursor
      libxext
      libxrandr
      libxxf86vm

      # lwjgl
      (lib.getLib stdenv.cc.cc)

      # narrator support
      flite

      # openal
      alsa-lib
      libjack2
      libpulseaudio
      pipewire

      # oshi
      udev
    ]
  );

  meta = {
    inherit (modrinth-app-unwrapped.meta)
      description
      longDescription
      homepage
      license
      maintainers
      mainProgram
      platforms
      broken
      ;
  };
}
