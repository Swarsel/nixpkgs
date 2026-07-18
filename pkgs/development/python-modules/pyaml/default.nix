{
  lib,
  buildPythonPackage,
  fetchPypi,
  pyyaml,
  setuptools,
  unidecode,
}:

buildPythonPackage rec {
  pname = "pyaml";
  version = "25.7.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-4ROmTsFogb8rCS4r64S33PG9mAlq0X9fFOj7eCp12Zs=";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ pyyaml ];
  nativeCheckInputs = [ unidecode ];
  pyproject = true;
  pythonImportsCheck = [ "pyaml" ];

  meta = {
    description = "PyYAML-based module to produce pretty and readable YAML-serialized data";
    homepage = "https://github.com/mk-fg/pretty-yaml";
    license = lib.licenses.wtfpl;
    maintainers = [ ];
    mainProgram = "pyaml";
  };
}
