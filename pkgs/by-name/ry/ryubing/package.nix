{
  lib,
  stdenv,
  SDL2,
  SDL2_mixer,
  buildDotnetModule,
  cctools,
  darwin,
  dotnetCorePackages,
  fetchFromForgejo,
  ffmpeg,
  glew,
  gtk3,
  libGL,
  libgdiplus,
  libice,
  libsm,
  libsoundio,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxrandr,
  moltenvk,
  openal,
  pulseaudio,
  sndio,
  udev,
  vulkan-loader,
  wrapGAppsHook3,
}:

buildDotnetModule rec {
  pname = "ryubing";
  version = "1.3.3";

  src = fetchFromForgejo {
    owner = "projects";
    repo = "Ryubing";
    tag = version;
    hash = "sha256-LhQaXxmj5HIgfmrsDN8GhhVXlXHpDO2Q8JtNLaCq0mk=";
    domain = "git.ryujinx.app";
  };

  nativeBuildInputs =
    lib.optional stdenv.hostPlatform.isLinux wrapGAppsHook3
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      cctools
      darwin.sigtool
    ];

  # Tests on Darwin currently fail because of Ryujinx.Tests.Unicorn
  doCheck = !stdenv.hostPlatform.isDarwin;

  preInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    # workaround for https://github.com/Ryujinx/Ryujinx/issues/2349
    mkdir -p $out/lib/sndio-6
    ln -s ${sndio}/lib/libsndio.so $out/lib/sndio-6/libsndio.so.6
  '';

  preFixup = ''
    ${lib.optionalString stdenv.hostPlatform.isLinux ''
      mkdir -p $out/share/{applications,icons/hicolor/scalable/apps,mime/packages}

      pushd ${src}/distribution/linux

      install -D ./Ryujinx.desktop  $out/share/applications/Ryujinx.desktop
      install -D ./Ryujinx.sh       $out/bin/Ryujinx.sh
      install -D ./mime/Ryujinx.xml $out/share/mime/packages/Ryujinx.xml
      install -D ../misc/Logo.svg   $out/share/icons/hicolor/scalable/apps/Ryujinx.svg

      popd
    ''}

    # Don't make a softlink on OSX because of its case insensitivity
    ${lib.optionalString (!stdenv.hostPlatform.isDarwin) "ln -s $out/bin/Ryujinx $out/bin/ryujinx"}
  '';

  dotnet-runtime = dotnetCorePackages.runtime_9_0;
  dotnet-sdk = dotnetCorePackages.sdk_9_0;

  dotnetFlags = [
    "/p:ExtraDefineConstants=DISABLE_UPDATER%2CFORCE_EXTERNAL_BASE_DIR"
  ];

  enableParallelBuilding = false;

  executables = [
    "Ryujinx"
  ];

  makeWrapperArgs = lib.optional stdenv.hostPlatform.isLinux [
    # Without this Ryujinx fails to start on wayland. See https://github.com/Ryujinx/Ryujinx/issues/2714
    "--set SDL_VIDEODRIVER x11"
  ];

  nugetDeps = ./deps.json;
  projectFile = "Ryujinx.sln";

  runtimeDeps = [
    libx11
    libgdiplus
    SDL2_mixer
    openal
    libsoundio
    sndio
    vulkan-loader
    ffmpeg

    # Avalonia UI
    glew
    libice
    libsm
    libxcursor
    libxext
    libxi
    libxrandr
    gtk3

    # Headless executable
    libGL
    SDL2
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    udev
    pulseaudio
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin moltenvk;

  testProjectFile = "src/Ryujinx.Tests/Ryujinx.Tests.csproj";
  passthru.updateScript = ./updater.sh;

  meta = {
    description = "Experimental Nintendo Switch Emulator written in C# (community fork of Ryujinx)";

    longDescription = ''
      Ryujinx is an open-source Nintendo Switch emulator, created by gdkchan,
      written in C#. This emulator aims at providing excellent accuracy and
      performance, a user-friendly interface and consistent builds. It was
      written from scratch and development on the project began in September
      2017. The project has since been abandoned on October 1st 2024 and QoL
      updates are now managed under a fork.
    '';

    homepage = "https://ryujinx.app";
    # historical changelog https://git.ryujinx.app/projects/Ryubing/wiki/Changelog
    changelog = "https://git.ryujinx.app/projects/Ryubing/releases/tag/${src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jk
      artemist
      willow
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "Ryujinx";
  };
}
