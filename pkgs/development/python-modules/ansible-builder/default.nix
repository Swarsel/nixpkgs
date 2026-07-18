{
  lib,
  bindep,
  buildPythonPackage,
  fetchPypi,
  jsonschema,
  packaging,
  podman,
  pyyaml,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "ansible-builder";
  version = "3.1.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-nYi8FazH0xBW0MUZFKYQLayOWtc/ny01upg3jIlxTtI=";
    pname = "ansible_builder";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    podman
    bindep
    jsonschema
    pyyaml
    packaging
  ];

  patchPhase = ''
    # the upper limits of setuptools are unnecessary
    # See https://github.com/ansible/ansible-builder/issues/639
    sed -i 's/, <=[0-9.]*//g' pyproject.toml
  '';

  pyproject = true;

  meta = {
    description = "Ansible execution environment builder";
    homepage = "https://ansible-builder.readthedocs.io/en/stable/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ melkor333 ];
  };
}
