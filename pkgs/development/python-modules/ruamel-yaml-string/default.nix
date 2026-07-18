{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonAtLeast,
  ruamel-yaml,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "ruamel-yaml-string";
  version = "0.1.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-enrtzAVdRcAE04t1b1hHTr77EGhR9M5WzlhBVwl4Q1A=";
    pname = "ruamel.yaml.string";
  };

  build-system = [ setuptools ];
  dependencies = [ ruamel-yaml ];
  # ImportError: cannot import name 'Str' from 'ast'
  disabled = pythonAtLeast "3.14";
  pyproject = true;
  pythonImportsCheck = [ "ruamel.yaml" ];

  meta = {
    description = "Add dump_to_string/dumps method that returns YAML document as string";
    homepage = "https://sourceforge.net/projects/ruamel-yaml-string/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fbeffa ];
  };
})
