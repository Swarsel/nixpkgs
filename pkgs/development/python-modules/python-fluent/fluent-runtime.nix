{
  lib,
  fetchFromGitHub,
  # dependencies
  attrs,
  babel,
  buildPythonPackage,
  fluent-syntax,
  pytestCheckHook,
  pytz,
  setuptools,
  typing-extensions,
}:

let
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "projectfluent";
    repo = "python-fluent";
    rev = "fluent.runtime@${version}";
    hash = "sha256-Crg6ybweOZ4B3WfLMOcD7+TxGEZPTHJUxr8ItLB4G+Y=";
  };
in
buildPythonPackage {
  inherit version;
  inherit src;
  pname = "fluent-runtime";
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    attrs
    babel
    fluent-syntax
    pytz
    typing-extensions
  ];

  disabledTests = [
    # https://github.com/projectfluent/python-fluent/pull/203
    "test_timeZone"
  ];

  pyproject = true;
  pythonImportsCheck = [ "fluent.runtime" ];
  sourceRoot = "${src.name}/fluent.runtime";

  meta = {
    description = "Localization library for expressive translations";
    homepage = "https://projectfluent.org/python-fluent/fluent.runtime/${version}";
    changelog = "https://github.com/projectfluent/python-fluent/blob/${src.rev}/fluent.runtime/CHANGELOG.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ getpsyched ];
    downloadPage = "https://github.com/projectfluent/python-fluent/releases/tag/${src.rev}";
  };
}
