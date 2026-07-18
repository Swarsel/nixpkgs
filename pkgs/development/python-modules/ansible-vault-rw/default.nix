{
  lib,
  # dependencies
  ansible-core,
  buildPythonPackage,
  fetchPypi,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "ansible-vault-rw";
  version = "2.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-XOj9tUcPFEm3a/B64qvFZIDa1INWrkBchbaG77ZNvV4";
    pname = "ansible-vault";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ ansible-core ];
  # no tests in sdist, no 2.1.0 tag on git
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];

  # Otherwise tests will fail to create directory
  # Permission denied: '/homeless-shelter'
  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  pyproject = true;

  meta = {
    description = "This project aim to R/W an ansible-vault yaml file";
    homepage = "https://github.com/tomoh1r/ansible-vault";
    changelog = "https://github.com/tomoh1r/ansible-vault/blob/master/CHANGES.txt";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ StillerHarpo ];
  };
}
