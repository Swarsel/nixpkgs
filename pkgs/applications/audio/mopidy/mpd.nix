{
  lib,
  fetchPypi,
  mopidy,
  pythonPackages,
}:

pythonPackages.buildPythonApplication (finalAttrs: {
  pname = "mopidy-mpd";
  version = "3.3.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-CeLMRqj9cwBvQrOx7XHVV8MjDjwOosONVlsN2o+vTVM=";
    pname = "Mopidy-MPD";
  };

  # no tests implemented
  doCheck = false;
  build-system = [ pythonPackages.setuptools ];
  dependencies = [ mopidy ];
  pyproject = true;
  pythonImportsCheck = [ "mopidy_mpd" ];

  meta = {
    description = "Mopidy extension for controlling playback from MPD clients";
    homepage = "https://github.com/mopidy/mopidy-mpd";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.tomahna ];
  };
})
