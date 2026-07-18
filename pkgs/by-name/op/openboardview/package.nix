{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  cmake,
  fetchpatch,
  fontconfig,
  gitUpdater,
  gtk3,
  pkg-config,
  python3,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "openboardview";
  version = "9.95.2";

  src = fetchFromGitHub {
    owner = "OpenBoardView";
    repo = "OpenBoardView";
    tag = version;
    hash = "sha256-B5VnuycRt8h7Cz3FTIbhcGcXuA60zPCz0FMvFENTwws=";
    fetchSubmodules = true;
  };

  patches = [
    (fetchpatch {
      hash = "sha256-DK+K4F0+QGqaoWCyc8AvuIsaiTCqhAG6AsTNg2hegh0=";
      name = "fix-darwin-build.patch";
      url = "https://github.com/OpenBoardView/OpenBoardView/commit/a1de2e5de908afd83eceed757260f6425314af2e.patch?full_index=1";
    })
  ];

  postPatch = ''
    substituteInPlace src/openboardview/CMakeLists.txt \
      --replace "SDL2::SDL2main" ""
    substituteInPlace CMakeLists.txt --replace "fixup_bundle" "#fixup_bundle"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    python3
    wrapGAppsHook3
  ];

  buildInputs = [
    SDL2
    fontconfig
    gtk3
  ];

  cmakeFlags = [
    "-DGLAD_REPRODUCIBLE=On"
  ];

  postFixup =
    lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p "$out/Applications"
      mv "$out/openboardview.app" "$out/Applications/OpenBoardView.app"
    ''
    + lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
      wrapGApp "$out/bin/${pname}" \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ gtk3 ]}
    '';

  dontWrapGApps = true;

  passthru.updateScript = gitUpdater {
    ignoredVersions = ''.*\.90\..*'';
  };

  meta = {
    description = "Linux SDL/ImGui edition software for viewing .brd files";
    homepage = "https://github.com/OpenBoardView/OpenBoardView";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ k3a ];
    platforms = lib.platforms.unix;
    mainProgram = "openboardview";
  };
}
