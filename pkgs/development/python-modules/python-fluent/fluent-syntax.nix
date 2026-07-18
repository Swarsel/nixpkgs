{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

let
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "projectfluent";
    repo = "python-fluent";
    rev = "fluent.syntax@${version}";
    hash = "sha256-nULngwBG/ebICRDi6HMHBdT+r/oq6tbDL7C1iMZpMsA=";
  };
in
buildPythonPackage {
  inherit version;
  inherit src;
  pname = "fluent-syntax";
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ typing-extensions ];
  pyproject = true;
  pythonImportsCheck = [ "fluent.syntax" ];
  sourceRoot = "${src.name}/fluent.syntax";

  meta = {
    description = "Parse, analyze, process, and serialize Fluent files";
    homepage = "https://projectfluent.org/python-fluent/fluent.syntax/${version}";
    changelog = "https://github.com/projectfluent/python-fluent/blob/${src.rev}/fluent.syntax/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ getpsyched ];
    downloadPage = "https://github.com/projectfluent/python-fluent/releases/tag/${src.rev}";
  };
}
