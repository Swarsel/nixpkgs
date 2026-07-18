{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  charset-normalizer,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aeidon";
  version = "1.15";

  src = fetchFromGitHub {
    owner = "otsaloma";
    repo = "gaupol";
    tag = version;
    hash = "sha256-lhNyeieeiBBm3rNDEU0BuWKeM6XYlOtv1voW8tR8cUM=";
  };

  postPatch = ''
    mv setup.py setup_gaupol.py
    substituteInPlace setup-aeidon.py \
      --replace "from setup import" "from setup_gaupol import"
    mv setup-aeidon.py setup.py
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ charset-normalizer ];

  disabledTests = [
    # requires gspell to work with gobject introspection
    "test_spell"
  ];

  enabledTestPaths = [ "aeidon/test" ];
  pyproject = true;
  pythonImportsCheck = [ "aeidon" ];

  meta = {
    description = "Reading, writing and manipulationg text-based subtitle files";
    homepage = "https://github.com/otsaloma/gaupol";
    changelog = "https://github.com/otsaloma/gaupol/releases/tag/${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ erictapen ];
  };

}
