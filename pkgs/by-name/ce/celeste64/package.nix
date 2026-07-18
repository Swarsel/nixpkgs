{
  lib,
  fetchFromGitHub,
  SDL2,
  buildDotnetModule,
  copyDesktopItems,
  dotnetCorePackages,
  libGL,
  libdecor,
  libdrm,
  libpulseaudio,
  libselinux,
  libx11,
  libxcursor,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  makeDesktopItem,
  systemd,
  wayland,
  withSELinux ? false,
}:

buildDotnetModule rec {
  pname = "celeste64";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "ExOK";
    repo = "Celeste64";
    rev = "v${version}";
    hash = "sha256-XRAjDYIqYaQYCWNNT7UuLDKDBgq3vqxtCzay7pGICtA=";
  };

  strictDeps = true;
  nativeBuildInputs = [ copyDesktopItems ];

  postInstall = ''
    export ICON_DIR=$out/share/icons/hicolor/256x256/apps
    mkdir -p $ICON_DIR

    cp -r $src/Content $out/lib/$pname/
    cp $src/Content/Models/Sources/logo1.png $ICON_DIR/Celeste64.png
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = meta.description;
      desktopName = "Celeste64";
      exec = "Celeste64";
      genericName = "Celeste64";
      icon = "Celeste64";
      name = "Celeste64";
    })
  ];

  dotnet-runtime = dotnetCorePackages.runtime_8_0;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  executables = [ "Celeste64" ];
  nugetDeps = ./deps.json;
  projectFile = "Celeste64.csproj";

  runtimeDeps = [
    libdecor
    libGL
    SDL2
    systemd
    libpulseaudio
    wayland
    libdrm
    libxkbcommon
    libx11
    libxfixes
    libxext
    libxcursor
    libxi
    libxrandr
  ]
  ++ lib.optionals withSELinux [ libselinux ];

  meta = {
    description = "Celeste 64: Fragments of the Mountain";
    homepage = "https://github.com/ExOK/Celeste64";

    license = with lib.licenses; [
      unfree
      mit
    ];

    maintainers = [ ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "armv7l-linux"
    ];

    mainProgram = "Celeste64";
    downloadPage = "https://maddymakesgamesinc.itch.io/celeste64";
  };
}
