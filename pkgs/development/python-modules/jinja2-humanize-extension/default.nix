{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  humanize,
  jinja2,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "jinja2-humanize-extension";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "metwork-framework";
    repo = "jinja2_humanize_extension";
    tag = "v${version}";
    hash = "sha256-bSSwPCPLIWIRhIgaSwHnVTj5mpvwn259GXYeGr5NHBQ=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    humanize
    jinja2
  ];

  pyproject = true;

  pythonImportsCheck = [
    "jinja2_humanize_extension"
  ];

  meta = {
    description = "Jinja2 extension to use humanize library inside jinja2 templates";
    homepage = "https://github.com/metwork-framework/jinja2_humanize_extension";
    changelog = "https://github.com/metwork-framework/jinja2_humanize_extension/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ happysalada ];
  };
}
