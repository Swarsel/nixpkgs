{
  lib,
  buildPythonPackage,
  click,
  fetchPypi,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "cloup";
  version = "3.1.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-Y3weYo/pjz8gpeRNpZGnK0K/VNfUUnGQvzntX2SvdYU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools-scm ];
  dependencies = [ click ];
  pyproject = true;
  pythonImportsCheck = [ "cloup" ];

  meta = {
    description = "Click extended with option groups, constraints, aliases, help themes";

    longDescription = ''
      Enriches Click with option groups, constraints, command aliases, help sections for
      subcommands, themes for --help and other stuff.
    '';

    homepage = "https://github.com/janLuke/cloup";
    changelog = "https://github.com/janluke/cloup/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
})
