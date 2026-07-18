{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
  tree,
  versionCheckHook,
}:
let
  version = "1.2.1";
in
python3Packages.buildPythonApplication {
  inherit version;
  pname = "stown";

  src = fetchFromGitHub {
    owner = "rseichter";
    repo = "stown";
    tag = version;
    hash = "sha256-B3gNFVeMRvN+bqBNCBLU1YqjGVz9wCbHUknWTTU8S6A=";
  };

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
    tree
    versionCheckHook
  ];

  build-system = [
    python3Packages.setuptools
  ];

  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Manage file system object mapping via symlinks. Lightweight alternative to GNU Stow";
    homepage = "https://www.seichter.de/stown/";
    changelog = "https://github.com/rseichter/stown/blob/${version}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ rseichter ];
    mainProgram = "stown";
  };
}
