{
  lib,
  stdenv,
  copyDesktopItems,
  fetchCrate,
  makeDesktopItem,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "oxker";
  version = "0.13.2";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-9kJ+oUwv3hAYANJ8RtVc1P3f15ImfeqXur1h8DT90Vg=";
  };

  nativeBuildInputs = [
    copyDesktopItems
  ];

  cargoHash = "sha256-Tv1+M3Xupdj7ZHsLw5eObGbw1gmVhDDDd3faY4O6mqM=";

  # See https://github.com/mrjackwills/oxker/issues/73
  checkFlags = lib.optionals stdenv.hostPlatform.isDarwin [
    "--skip=ui::draw_blocks::help::tests::test_draw_blocks_help_custom_keymap_one_definition"
    "--skip=ui::draw_blocks::help::tests::test_draw_blocks_help_custom_keymap_two_definitions"
    "--skip=ui::draw_blocks::help::tests::test_draw_blocks_help_one_and_two_definitions"
  ];

  postInstall = ''
    mkdir --parents $out/share/icons/hicolor/scalable/apps
    cp .github/logo.svg $out/share/icons/hicolor/scalable/apps/oxker.svg
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "System"
        "Utility"
        "Monitor"
        "ConsoleOnly"
      ];

      comment = finalAttrs.meta.description;
      desktopName = "oxker";
      exec = finalAttrs.meta.mainProgram;
      icon = "oxker";

      keywords = [
        "docker"
        "container"
      ];

      name = finalAttrs.pname;
      terminal = true;
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple TUI to view & control docker containers";
    homepage = "https://github.com/mrjackwills/oxker";
    changelog = "https://github.com/mrjackwills/oxker/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siph ];
    mainProgram = "oxker";
  };
})
