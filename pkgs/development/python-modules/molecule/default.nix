{
  lib,
  ansible-compat,
  ansible-core,
  buildPythonPackage,
  click-help-colors,
  enrich,
  fetchPypi,
  jsonschema,
  molecule,
  molecule-plugins,
  packaging,
  pluggy,
  rich,
  setuptools,
  setuptools-scm,
  testers,
  wcmatch,
  writableTmpDirAsHomeHook,
  yamllint,
  withPlugins ? true,
}:

buildPythonPackage rec {
  pname = "molecule";
  version = "26.6.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-GHDF9UQkA9d7WVPTRDgiZaUh60lIiFJgwMrAhKo97AI=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  propagatedBuildInputs = [
    ansible-compat
    ansible-core
    click-help-colors
    enrich
    jsonschema
    packaging
    pluggy
    rich
    yamllint
    wcmatch
  ]
  ++ lib.optional withPlugins molecule-plugins;

  # tests can't be easily run without installing things from ansible-galaxy
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "molecule" ];

  passthru.tests.version =
    (testers.testVersion {
      command = "PY_COLORS=0 ${pname} --version";
      package = molecule;
    }).overrideAttrs
      (old: {
        # workaround the error: Permission denied: '/homeless-shelter'
        nativeBuildInputs = old.nativeBuildInputs ++ [ writableTmpDirAsHomeHook ];
      });

  meta = {
    description = "Aids in the development and testing of Ansible roles";
    homepage = "https://github.com/ansible-community/molecule";
    changelog = "https://github.com/ansible/molecule/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "molecule";
  };
}
