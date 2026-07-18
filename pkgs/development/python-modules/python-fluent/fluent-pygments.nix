{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  fluent-syntax,
  pygments,
  pytestCheckHook,
  setuptools,
  six,
}:

let
  version = "1.0";

  src = fetchFromGitHub {
    owner = "projectfluent";
    repo = "python-fluent";
    rev = "fluent.pygments@${version}";
    hash = "sha256-AR2uce3HS1ELzpoHmx7F/5/nrL+7KhYemw/00nmvLik=";
  };
in
buildPythonPackage {
  inherit version;
  inherit src;
  pname = "fluent-pygments";
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    fluent-syntax
    pygments
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "fluent.pygments" ];
  sourceRoot = "${src.name}/fluent.pygments";

  meta = {
    description = "Plugin for pygments to add syntax highlighting of Fluent files in Sphinx";
    homepage = "https://projectfluent.org/python-fluent/fluent.pygments/${version}";
    changelog = "https://github.com/projectfluent/python-fluent/blob/main/fluent.pygments/CHANGELOG.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ getpsyched ];
  };
}
