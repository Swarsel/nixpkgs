{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  jansson,
  libsearpc,
  libuuid,
  nix-update-script,
  pkg-config,
  qt6,
  seadrive-fuse,
  seafile-shared,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "seadrive-gui";
  version = "3.0.23";

  src = fetchFromGitHub {
    owner = "haiwen";
    repo = "seadrive-gui";
    rev = "v${finalAttrs.version}";
    hash = "sha256-FnZ96NkS31xC5iImZToz6lRjpJ0ui4UbrTGyA9ij7y8=";
  };

  # Fix cmake modernization warning.
  # Avoid mixed use of plain signature and keyword signature
  # for all seadrive-gui targets in target_link_libraries.
  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail \
      'CMAKE_MINIMUM_REQUIRED(VERSION 2.8.9)' \
      'CMAKE_MINIMUM_REQUIRED(VERSION 3.10)'; \
    substituteInPlace CMakeLists.txt --replace-fail \
      'TARGET_LINK_LIBRARIES(seadrive-gui PRIVATE Qt6::DBus)' \
      'TARGET_LINK_LIBRARIES(seadrive-gui Qt6::DBus)'
  '';

  nativeBuildInputs = [
    libuuid
    pkg-config
    cmake
    qt6.wrapQtAppsHook
    qt6.qttools
  ];

  buildInputs = [
    qt6.qt5compat
    seafile-shared
    jansson
    libsearpc
    seadrive-fuse
    qt6.qtwebengine
  ];

  qtWrapperArgs = [
    "--suffix PATH : ${lib.makeBinPath [ seadrive-fuse ]}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "GUI part of Seafile drive";
    homepage = "https://github.com/haiwen/seadrive-gui";
    changelog = "https://github.com/haiwen/seadrive-gui/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      wenbin-liu
    ];

    platforms = lib.platforms.linux;
    mainProgram = "seadrive-gui";
  };
})
