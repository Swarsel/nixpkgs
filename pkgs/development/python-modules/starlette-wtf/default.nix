{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  itsdangerous,
  jinja2,
  pytestCheckHook,
  python-multipart,
  setuptools,
  starlette,
  wtforms,
}:

buildPythonPackage rec {
  pname = "starlette-wtf";
  version = "0.4.5";

  src = fetchFromGitHub {
    owner = "muicss";
    repo = "starlette-wtf";
    tag = version;
    hash = "sha256-88zU2NAsdty2OhHauwQ5+6LazuRDYPoqN9IIipI1t2Q=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    itsdangerous
    python-multipart
    starlette
    wtforms
  ];

  nativeCheckInputs = [
    pytestCheckHook
    httpx
    jinja2
  ];

  pyproject = true;

  meta = {
    description = "Simple tool for integrating Starlette and WTForms";
    homepage = "https://github.com/muicss/starlette-wtf";
    changelog = "https://github.com/amorey/starlette-wtf/releases/tag/${version}";
    license = lib.licenses.mit;
  };
}
