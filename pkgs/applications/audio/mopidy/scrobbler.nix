{
  lib,
  fetchPypi,
  mopidy,
  pythonPackages,
}:

pythonPackages.buildPythonApplication (finalAttrs: {
  pname = "mopidy-scrobbler";
  version = "2.0.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    sha256 = "11vxgax4xgkggnq4fr1rh2rcvzspkkimck5p3h4phdj3qpnj0680";
    pname = "Mopidy-Scrobbler";
  };

  # no tests implemented
  doCheck = false;

  build-system = [
    pythonPackages.setuptools
  ];

  dependencies = [
    mopidy
    pythonPackages.pylast
  ];

  pyproject = true;
  pythonImportsCheck = [ "mopidy_scrobbler" ];

  meta = {
    description = "Mopidy extension for scrobbling played tracks to Last.fm";
    homepage = "https://github.com/mopidy/mopidy-scrobbler";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jakeisnt ];
  };
})
