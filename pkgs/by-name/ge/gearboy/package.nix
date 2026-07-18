{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  libGL,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
  pkg-config,
  sdl3,
  versionCheckHook,
}:
let
  inherit (stdenv.targetPlatform) isLinux isDarwin;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "gearboy";
  version = "3.8.9";

  src = fetchFromGitHub {
    owner = "drhelius";
    repo = "Gearboy";
    tag = finalAttrs.version;
    hash = "sha256-p6gIGWkcv4jJacF4baK8Uej2kwwPnd/ylvgmUHHPXnI=";
  };

  postPatch = ''
    substituteInPlace platforms/shared/makefiles/Makefile.common \
      --replace-fail 'GIT_VERSION := $(shell git describe --abbrev=7 --dirty --always --tags)' \
                     'GIT_VERSION := ${finalAttrs.version}'
  ''
  # point the Linux binary to the `$out/opt/gearboy` location
  + lib.optionalString isLinux ''
    substituteInPlace platforms/shared/desktop/gamepad.cpp \
      --replace-fail 'db_path = std::string(exe_path) + "/gamecontrollerdb.txt";' \
                     'db_path = std::string(exe_path) + "/../opt/gearboy/gamecontrollerdb.txt";'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
  ]
  ++ lib.optional isLinux copyDesktopItems
  ++ lib.optional isDarwin makeWrapper;

  buildInputs = [
    libGL
    sdl3
  ];

  makeFlags =
    lib.optional isLinux "-Cplatforms/linux"
    ++ lib.optional isDarwin "-Cplatforms/macos"
    ++ lib.optional stdenv.cc.isClang "USE_CLANG=1";

  installPhase = ''
    runHook preInstall
  ''
  + lib.optionalString isLinux ''
    install -Dm755 platforms/linux/gearboy -t $out/bin
    install -Dm644 platforms/shared/gamecontrollerdb.txt -t $out/opt/gearboy
  ''
  + lib.optionalString isDarwin ''
    # create the Gearboy.app bundle
    make $makeFlags bundle

    mkdir -p $out/{bin,Applications}
    cp -r platforms/macos/Gearboy.app $out/Applications/Gearboy.app

    # using makeWrapper rather than a link, to have the `db_path` work in both
    # the $out/bin binary and the App
    makeWrapper $out/Applications/Gearboy.app/Contents/MacOS/gearboy $out/bin/gearboy
  ''
  + ''
    runHook postInstall
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;

  desktopItems = lib.optionals isLinux [
    (makeDesktopItem {
      categories = [
        "Game"
        "Emulator"
      ];

      comment = finalAttrs.meta.description;
      desktopName = "Gearboy";
      exec = finalAttrs.meta.mainProgram;
      genericName = "Game Boy Emulator";
      name = "Gearboy";
      type = "Application";
    })
  ];

  enableParallelBuilding = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Game Boy/Game Boy Color/Super Game Boy emulator, debugger and embedded MCP server for macOS, Windows, Linux, BSD and RetroArch";
    homepage = "https://github.com/drhelius/Gearboy";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.nekowinston ];
    mainProgram = "gearboy";
  };
})
