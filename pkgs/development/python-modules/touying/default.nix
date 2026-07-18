{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  jinja2,
  pillow,
  python-pptx,
  # build-system
  setuptools,
  typst,
}:

buildPythonPackage rec {
  pname = "touying";
  version = "0.14.4";

  src = fetchFromGitHub {
    owner = "touying-typ";
    repo = "touying-exporter";
    tag = version;
    hash = "sha256-3e5LWI3ysklTj9WY0PF4+7spEARZYel/aS1R+elfMp0=";
  };

  # no tests
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    jinja2
    pillow
    python-pptx
    typst
  ];

  pyproject = true;
  pythonImportsCheck = [ "touying" ];

  meta = {
    description = "Export presentation slides in various formats for Touying";
    homepage = "https://github.com/touying-typ/touying-exporter";
    changelog = "https://github.com/touying-typ/touying-exporter/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    mainProgram = "touying";
  };
}
