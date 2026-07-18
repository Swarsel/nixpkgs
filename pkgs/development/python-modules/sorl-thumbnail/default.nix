{
  lib,
  buildPythonPackage,
  django,
  fetchPypi,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "sorl-thumbnail";
  version = "12.11.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-GRuJwn7LQLXCo1VJ1VfRfEhBxq/0ObLhe5OLke6kY7M=";
    pname = "sorl_thumbnail";
  };

  buildInputs = [ django ];
  env.DJANGO_SETTINGS_MODULE = "sorl.thumbnail.conf.defaults";
  # Disabled due to an improper configuration error when tested against django. This looks like something broken in the test cases for sorl.
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "sorl.thumbnail" ];

  meta = {
    description = "Thumbnails for Django";
    homepage = "https://sorl-thumbnail.readthedocs.org/en/latest/";
    changelog = "https://github.com/jazzband/sorl-thumbnail/blob/${version}/CHANGES.rst";
    license = lib.licenses.bsd3;
  };
}
