{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "circup";
  version = "3.0.4";

  src = fetchFromGitHub {
    owner = "adafruit";
    repo = "circup";
    tag = finalAttrs.version;
    hash = "sha256-sv+ixo5S9JRuVu8JkKt29Kpn1ioRIwGW4Ss/A77YiFU=";
  };

  postBuild = ''
    export HOME=$(mktemp -d);
  '';

  nativeCheckInputs = with python3.pkgs; [ pytestCheckHook ];
  build-system = with python3.pkgs; [ setuptools-scm ];

  dependencies = with python3.pkgs; [
    appdirs
    click
    findimports
    requests
    semver
    setuptools
    toml
    update-checker
  ];

  disabledTests = [
    # Test requires network access
    "test_libraries_from_imports_bad"
    "test_install_auto_file_bad"
  ];

  pyproject = true;
  pythonImportsCheck = [ "circup" ];
  pythonRelaxDeps = [ "semver" ];

  meta = {
    description = "CircuitPython library updater";
    homepage = "https://github.com/adafruit/circup";
    changelog = "https://github.com/adafruit/circup/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "circup";
  };
})
