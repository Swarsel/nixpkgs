{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "cogapp";
  version = "3.6.0";

  src = fetchFromGitHub {
    owner = "nedbat";
    repo = "cog";
    tag = "v${version}";
    hash = "sha256-46ojLTu1elNcjmWSKJuGKDG4XETLLnJDIpL2Al6/aX0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "cogapp" ];

  meta = {
    description = "Code generator for executing Python snippets in source files";
    homepage = "https://nedbatchelder.com/code/cog";
    changelog = "https://github.com/nedbat/cog/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
