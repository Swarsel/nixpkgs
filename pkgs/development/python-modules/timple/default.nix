{
  # lib & utils
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # deps
  matplotlib,
  nix-update-script,
  numpy,
  pandas,
  # tests
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "timple";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "theOehrly";
    repo = "timple";
    tag = "v${version}";
    hash = "sha256-tfw+m1ZrU5A9KbXmMS4c1AIP4f/9YT3/o7HRb/uxUSM";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pandas
  ];

  build-system = [ setuptools ];

  dependencies = [
    matplotlib
    numpy
  ];

  disabledTestPaths = [
    # gui plotting tests
    "timple/tests/test_timple.py"
  ];

  disabledTests = [
    # wants write access to nix store
    "test_mpl_default_functionality"
  ];

  pyproject = true;
  pythonImportsCheck = [ "timple" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Extended functionality for plotting timedelta-like values with Matplotlib";
    homepage = "https://github.com/theOehrly/timple";
    changelog = "https://github.com/theOehrly/timple/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vaisriv ];
  };
}
