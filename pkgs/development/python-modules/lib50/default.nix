{
  lib,
  attrs,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  jellyfish,
  pexpect,
  pytestCheckHook,
  pyyaml,
  requests,
  setuptools,
  termcolor,
}:

buildPythonPackage rec {
  pname = "lib50";
  version = "3.2.1";

  # latest GitHub release is several years old. Pypi is up to date.
  src = fetchPypi {
    inherit version;
    hash = "sha256-p+g7rMxrpfMVmeWfzy9wh//dhF0L5H922dkqyqlWolM=";
    pname = "lib50";
  };

  # latest GitHub release is several years old and doesn't include
  # tests and neither does pypi version include tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    attrs
    pexpect
    pyyaml
    requests
    termcolor
    jellyfish
    cryptography
  ];

  pyproject = true;
  pythonImportsCheck = [ "lib50" ];

  pythonRelaxDeps = [
    "attrs"
    "pyyaml"
    "termcolor"
    "jellyfish"
  ];

  meta = {
    description = "CS50's own internal library used in many of its tools";
    homepage = "https://github.com/cs50/lib50";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    platforms = lib.platforms.unix;
  };
}
