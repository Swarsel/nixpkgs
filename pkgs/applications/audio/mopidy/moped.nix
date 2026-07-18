{
  lib,
  fetchPypi,
  glibcLocales,
  mopidy,
  pythonPackages,
}:

pythonPackages.buildPythonApplication (finalAttrs: {
  pname = "mopidy-moped";
  version = "0.7.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    sha256 = "15461174037d87af93dd59a236d4275c5abf71cea0670ffff24a7d0399a8a2e4";
    pname = "Mopidy-Moped";
  };

  buildInputs = [ glibcLocales ];
  env.LC_ALL = "en_US.UTF-8";
  # no tests implemented
  doCheck = false;
  build-system = [ pythonPackages.setuptools ];
  dependencies = [ mopidy ];
  pyproject = true;
  pythonImportsCheck = [ "mopidy_moped" ];

  meta = {
    description = "Web client for Mopidy";
    homepage = "https://github.com/martijnboland/moped";
    license = lib.licenses.mit;
    maintainers = [ ];
    hydraPlatforms = [ ];
  };
})
