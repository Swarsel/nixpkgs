{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "colorlog";
  version = "6.10.1";

  src = fetchFromGitHub {
    owner = "borntyping";
    repo = "python-colorlog";
    tag = "v${version}";
    hash = "sha256-vb7OzIVcEIfnhJGpO0DgeEdhL6NCKlrynoNMxNp8Yg4=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "colorlog" ];

  meta = {
    description = "Log formatting with colors";
    homepage = "https://github.com/borntyping/python-colorlog";
    changelog = "https://github.com/borntyping/python-colorlog/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
