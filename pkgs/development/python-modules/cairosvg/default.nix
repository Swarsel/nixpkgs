{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  cairocffi,
  cssselect2,
  defusedxml,
  pillow,
  # testing
  pytestCheckHook,
  # build-system
  setuptools,
  tinycss2,
}:

buildPythonPackage rec {
  pname = "cairosvg";
  version = "2.9.0";

  src = fetchFromGitHub {
    owner = "Kozea";
    repo = "CairoSVG";
    tag = version;
    hash = "sha256-WtMFOYaN/cRrL1Q4ma/UkR3kNFObNhp0Gm7i9NQAqz8=";
  };

  nativeBuildInputs = [ cairocffi ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    cairocffi
    cssselect2
    defusedxml
    pillow
    tinycss2
  ];

  enabledTestPaths = [ "cairosvg/test_api.py" ];
  pyproject = true;
  pythonImportsCheck = [ "cairosvg" ];

  meta = {
    description = "SVG converter based on Cairo";
    homepage = "https://cairosvg.org";
    changelog = "https://github.com/Kozea/CairoSVG/releases/tag/${version}";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ lib.maintainers.sarahec ];
    mainProgram = "cairosvg";
  };
}
