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
  jdk8,
  libGL,
  libjack2,
  libpulseaudio,
  libx11,
  libxcursor,
  libxext,
  libxrandr,
  libxxf86vm,
  noriskclient-launcher-unwrapped,
  pipewire,
  symlinkJoin,
  udev,
  wrapGAppsHook4,
  jdks ? [
    jdk8
    jdk17
    jdk21
  ],
}:

symlinkJoin {
  inherit (noriskclient-launcher-unwrapped) version;
  pname = "noriskclient-launcher";
  strictDeps = true;

  nativeBuildInputs = [
    glib
    wrapGAppsHook4
  ];

  buildInputs = [
    glib-networking
    gsettings-desktop-schemas
  ];

  postBuild = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${lib.makeSearchPath "bin/java" jdks}
      ${lib.optionalString stdenv.hostPlatform.isLinux ''
        --set LD_LIBRARY_PATH $runtimeDependencies
      ''}
    )

    glibPostInstallHook
    gappsWrapperArgsHook
    wrapGAppsHook
  '';

  paths = [ noriskclient-launcher-unwrapped ];

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
    inherit (noriskclient-launcher-unwrapped.meta)
      description
      homepage
      license
      longDescription
      maintainers
      mainProgram
      platforms
      ;
  };
}
