{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonPackage rec {
  pname = "nixoscope";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "giomf";
    repo = "nixoscope";
    tag = "v${version}";
    hash = "sha256-9w5+KgC1daxGZ0BEVX75bKExpdnzik5pFnOPGHLDtiQ=";
  };

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    graphviz
  ];

  pyproject = true;

  unittestFlags = [
    "-s"
    "tests"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Visualize dependencies between NixOS modules";
    homepage = "https://github.com/giomf/NixoScope";

    license = with lib.licenses; [
      mit
    ];

    maintainers = with lib.maintainers; [
      giomf
    ];

    mainProgram = "nixoscope";
  };
}
