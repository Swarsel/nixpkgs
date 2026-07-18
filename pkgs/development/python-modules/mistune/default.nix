{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "mistune";
  version = "3.3.2";

  src = fetchFromGitHub {
    owner = "lepture";
    repo = "mistune";
    tag = "v${version}";
    hash = "sha256-uyOJFtDvVn0Y3VypphOXsSW3pX5XVCcfQ7dtFiL/5qY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "mistune" ];

  meta = {
    description = "Sane Markdown parser with useful plugins and renderers";
    homepage = "https://github.com/lepture/mistune";
    changelog = "https://github.com/lepture/mistune/blob/${src.tag}/docs/changes.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
