{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  essentials,
  flask,
  hatchling,
  httpx,
  jinja2,
  markupsafe,
  pydantic,
  pytestCheckHook,
  pyyaml,
  rich,
  setuptools,
}:
buildPythonPackage rec {
  pname = "essentials-openapi";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "Neoteroi";
    repo = "essentials-openapi";
    tag = "v${version}";
    hash = "sha256-m2N6iOWfDBSRU99XqKs0T3a3iJWkPb2DuXW0Wm72r9g=";
  };

  nativeBuildInputs = [ hatchling ];

  propagatedBuildInputs = [
    pyyaml
    essentials
    markupsafe
  ];

  nativeCheckInputs = [
    flask
    httpx
    pydantic
    pytestCheckHook
    rich
    setuptools
  ];

  disabledTestPaths = lib.optionals stdenv.hostPlatform.isDarwin [
    # These tests start a server using a hardcoded port, and since
    # multiple Python versions are always built simultaneously, this
    # failure is quite likely to occur.
    "tests/test_cli.py"
  ];

  optional-dependencies = {
    full = [
      click
      jinja2
      rich
      httpx
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "openapidocs" ];

  pythonRelaxDeps = [
    "markupsafe"
  ];

  meta = {
    description = "Functions to handle OpenAPI Documentation";
    homepage = "https://github.com/Neoteroi/essentials-openapi";
    changelog = "https://github.com/Neoteroi/essentials-openapi/releases/${src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      aldoborrero
      zimbatm
    ];
  };
}
