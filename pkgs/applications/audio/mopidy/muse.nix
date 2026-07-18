{
  lib,
  fetchPypi,
  mopidy,
  pythonPackages,
}:

pythonPackages.buildPythonApplication (finalAttrs: {
  pname = "mopidy-muse";
  version = "0.0.33";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-CEPAPWtMrD+HljyqBB6EAyGVeOjzkvVoEywlE4XEJGs=";
    pname = "Mopidy-Muse";
  };

  # has no tests
  doCheck = false;

  build-system = [
    pythonPackages.setuptools
  ];

  dependencies = [
    mopidy
    pythonPackages.pykka
  ];

  pyproject = true;
  pythonImportsCheck = [ "mopidy_muse" ];

  meta = {
    description = "Mopidy web client with Snapcast support";
    homepage = "https://github.com/cristianpb/muse";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
