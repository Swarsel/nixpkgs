{
  lib,
  buildPythonPackage,
  editorconfig,
  fetchPypi,
  jsbeautifier,
  setuptools,
}:

buildPythonPackage rec {
  pname = "cssbeautifier";
  version = "2.0.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-LC/RKTQlYQKd6GsXRO+iMcn6/iYCPbyYih3rDKD1yEU=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    editorconfig
    jsbeautifier
  ];

  # Module has no tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "cssbeautifier" ];

  meta = {
    description = "CSS unobfuscator and beautifier";
    homepage = "https://github.com/beautifier/js-beautify";
    changelog = "https://github.com/beautifier/js-beautify/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ traxys ];
    mainProgram = "css-beautify";
  };
}
