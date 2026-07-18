{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  buildDotnetModule,
  copyDesktopItems,
  dbus,
  dotnetCorePackages,
  fontconfig,
  libxi,
  makeDesktopItem,
  portaudio,
}:

buildDotnetModule rec {
  pname = "OpenUtau";
  version = "0.1.565";

  src = fetchFromGitHub {
    owner = "stakira";
    repo = "OpenUtau";
    tag = version;
    hash = "sha256-tjW1xmt409AlEmw/N1RG46oigP4mWAoTecQGV/hwMo4=";
  };

  nativeBuildInputs = [ copyDesktopItems ];
  # socket cannot bind to localhost on darwin for tests
  doCheck = !stdenv.hostPlatform.isDarwin;

  # need to make sure proprietary worldline resampler is copied
  postInstall =
    let
      runtime =
        if (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64) then
          "linux-x64"
        else if (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64) then
          "linux-arm64"
        else if stdenv.hostPlatform.isDarwin then
          "osx"
        else
          null;
      shouldInstallResampler = lib.optionalString (runtime != null) ''
        cp runtimes/${runtime}/native/libworldline${stdenv.hostPlatform.extensions.sharedLibrary} $out/lib/OpenUtau/
      '';
      shouldInstallDesktopItem = lib.optionalString stdenv.hostPlatform.isLinux ''
        install -Dm655 -t $out/share/icons/hicolor/scalable/apps Logo/openutau.svg
      '';
    in
    ''
      ${shouldInstallResampler}
      ${shouldInstallDesktopItem}
    '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "AudioVideo"
        "Music"
      ];

      comment = "Open source UTAU successor";
      desktopName = "OpenUtau";
      exec = "OpenUtau";
      genericName = "Utau";
      icon = "openutau";
      name = "openutau";
      startupWMClass = "openutau";
    })
  ];

  dotnet-runtime = dotnetCorePackages.runtime_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnetInstallFlags = [ "-p:PublishReadyToRun=false" ];
  # [...]/Microsoft.NET.Sdk.targets(157,5): error MSB4018: The "GenerateDepsFile" task failed unexpectedly. [[...]/OpenUtau.Core.csproj]
  # [...]/Microsoft.NET.Sdk.targets(157,5): error MSB4018: System.IO.IOException: The process cannot access the file '[...]/OpenUtau.Core.deps.json' because it is being used by another process. [[...]/OpenUtau.Core.csproj]
  enableParallelBuilding = false;
  executables = [ "OpenUtau" ];
  nugetDeps = ./deps.json;
  projectFile = "OpenUtau.sln";

  runtimeDeps = [
    dbus
    portaudio
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    fontconfig
    libxi
  ];

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Open source singing synthesis platform and UTAU successor";
    homepage = "http://www.openutau.com/";
    license = lib.licenses.mit;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      # deps
      binaryBytecode
      # some deps and worldline resampler
      binaryNativeCode
    ];

    maintainers = [ ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "OpenUtau";
  };
}
