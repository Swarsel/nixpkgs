{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "gemfileparser2";
  version = "0.9.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ezfioBwlZMGb1cEzzwa1afXUrTnxsgpzX0CNOTyVzgY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dontConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "gemfileparser2" ];

  meta = {
    description = "Library to parse Rubygem gemspec and Gemfile files";
    homepage = "https://github.com/aboutcode-org/gemfileparser2";
    changelog = "https://github.com/aboutcode-org/gemfileparser2/blob/v${version}/CHANGELOG.rst";

    license = with lib.licenses; [
      mit # or
      gpl3Plus
    ];

    maintainers = with lib.maintainers; [ harvidsen ];
  };
}
