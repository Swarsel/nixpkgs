{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  mkdocs,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "mkdocs-redirects";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "mkdocs";
    repo = "mkdocs-redirects";
    tag = "v${version}";
    hash = "sha256-YsMA00yajeGSqSB6CdKxGqyClC9Cgc3ImRBTucHEHhs=";
  };

  propagatedBuildInputs = [ mkdocs ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "mkdocs_redirects" ];

  meta = {
    description = "Open source plugin for Mkdocs page redirects";
    homepage = "https://github.com/mkdocs/mkdocs-redirects";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tfc ];
  };
}
