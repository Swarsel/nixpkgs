{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  copyDesktopItems,
  libglvnd,
  libxkbcommon,
  makeDesktopItem,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  wrapGAppsHook3,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ukmm";
  version = "0.17.1";

  src = fetchFromGitHub {
    owner = "NiceneNerd";
    repo = "ukmm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1qhBBa6Mzo8XqvzwiHKnP0W9Oo26nvMiwZTzRAnLtfs=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapGAppsHook3
    copyDesktopItems
  ];

  buildInputs = [
    libglvnd
    libxkbcommon
    openssl
  ];

  cargoHash = "sha256-I39SPTBH4JUx5z65eD2w2ntWKfjWSxweSco6QE9V5sM=";

  # Force linking to libEGL, which is always dlopen()ed, and to
  # libwayland-client & libxkbcommon, which is dlopen()ed based on the
  # winit backend.
  env.NIX_LDFLAGS = toString [
    "--push-state"
    "--no-as-needed"
    "-lEGL"
    "-lwayland-client"
    "-lxkbcommon"
    "--pop-state"
  ];

  checkFlags = [
    # Requires a game dump of Breath of the Wild
    "--skip=gui::tasks::tests::remerge"
    "--skip=pack::tests::pack_mod"
    "--skip=project::tests::project_from_mod"
    "--skip=tests::read_meta"
    "--skip=unpack::tests::read_mod"
    "--skip=unpack::tests::unpack_mod"
    "--skip=unpack::tests::unzip_mod"

    # Requires Clear Camera mod
    "--skip=bnp::test_convert"
  ];

  postInstall = ''
    install -Dm444 assets/ukmm.png  $out/share/icons/hicolor/256x256/apps/ukmm.png
  '';

  cargoTestFlags = [
    "--all"
  ];

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
        "Utility"
      ];

      comment = "Breath of the Wild Mod Manager";
      desktopName = "UKMM";
      exec = "ukmm %u";
      icon = "ukmm";
      mimeTypes = [ "x-scheme-handler/bcml" ];
      name = "ukmm";
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "New mod manager for The Legend of Zelda: Breath of the Wild";
    homepage = "https://github.com/NiceneNerd/ukmm";
    changelog = "https://github.com/NiceneNerd/ukmm/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ kira-bruneau ];
    platforms = lib.platforms.linux;
    mainProgram = "ukmm";
    broken = stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64;
  };
})
