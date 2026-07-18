{
  lib,
  buildPythonPackage,
  fetchPypi,
  pyyaml,
  uv-build,
}:

buildPythonPackage rec {
  pname = "pyinfra-testgen";
  version = "0.1.1";

  # no tags on GitHub
  src = fetchPypi {
    inherit version;
    hash = "sha256-c5pZ0SfRXC50vJZfnnf0HQgImf7hi2oQ5/XKMVNzlpc=";
    pname = "pyinfra_testgen";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.8.14,<0.9.0" uv_build
  '';

  # upstream has no tests
  doCheck = false;
  build-system = [ uv-build ];

  dependencies = [
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "testgen" ];

  meta = {
    description = "Generate Python unit tests from JSON and YAML files";
    homepage = "https://github.com/pyinfra-dev/testgen";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
