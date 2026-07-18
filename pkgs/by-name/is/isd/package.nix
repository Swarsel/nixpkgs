{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "isd";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "kainctl";
    repo = "isd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aIVZvsmIZRHKg7267wxWzmcwAqleu4i7z5GHSNJi260=";
  };

  build-system = with python3Packages; [
    hatchling
    setuptools
  ];

  dependencies = with python3Packages; [
    pfzy
    pydantic
    pydantic-settings
    pyyaml
    textual
    types-pyyaml
    xdg-base-dirs
  ];

  pyproject = true;

  pythonImportsCheck = [
    "isd_tui"
  ];

  pythonRelaxDeps = [
    "pydantic"
    "pydantic-settings"
    "types-pyyaml"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "TUI to interactively work with systemd units";

    longDescription = ''
      isd (interactive systemd) is a TUI offering fuzzy search for systemd
      units, auto-refreshing previews, smart `sudo` handling, and a fully
      customizable interface for power-users and newcomers alike.
    '';

    homepage = "https://github.com/kainctl/isd";
    changelog = "https://github.com/kainctl/isd/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      gepbird
    ];

    platforms = lib.platforms.linux;
    mainProgram = "isd";
  };
})
