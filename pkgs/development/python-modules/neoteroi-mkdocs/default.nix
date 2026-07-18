{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  essentials-openapi,
  flask,
  hatchling,
  httpx,
  jinja2,
  mkdocs,
  pytestCheckHook,
  rich,
  setuptools,
}:
buildPythonPackage rec {
  pname = "neoteroi-mkdocs";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "Neoteroi";
    repo = "mkdocs-plugins";
    tag = "v${version}";
    hash = "sha256-l5jJCmsBns1bGv+yBA0R6TDlfQuweFr92kNnQalWB7k=";
  };

  buildInputs = [ hatchling ];

  propagatedBuildInputs = [
    essentials-openapi
    click
    jinja2
    httpx
    mkdocs
    rich
  ];

  nativeCheckInputs = [
    pytestCheckHook
    flask
    setuptools
  ];

  disabledTestPaths = lib.optionals stdenv.hostPlatform.isDarwin [
    # These tests start a server using a hardcoded port, and since
    # multiple Python versions are always built simultaneously, this
    # failure is quite likely to occur.
    "tests/test_http.py"
  ];

  disabledTests = [
    "test_contribs" # checks against its own git repository
  ];

  pyproject = true;
  pythonImportsCheck = [ "neoteroi.mkdocs" ];

  meta = {
    description = "Plugins for MkDocs";
    homepage = "https://github.com/Neoteroi/mkdocs-plugins";
    changelog = "https://github.com/Neoteroi/mkdocs-plugins/releases/${src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      aldoborrero
      zimbatm
    ];
  };
}
