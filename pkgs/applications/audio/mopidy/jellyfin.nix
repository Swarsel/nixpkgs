{
  lib,
  fetchPypi,
  mopidy,
  pythonPackages,
}:

pythonPackages.buildPythonApplication (finalAttrs: {
  pname = "mopidy-jellyfin";
  version = "1.0.6";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-IKCPypMuluR0+mMALp8lB1oB1pSw4rN4rOl/eKn+Qvo=";
    pname = "mopidy_jellyfin";
  };

  # no tests implemented
  doCheck = false;
  build-system = [ pythonPackages.setuptools ];

  dependencies = [
    mopidy
    pythonPackages.unidecode
    pythonPackages.websocket-client
  ];

  pyproject = true;
  pythonImportsCheck = [ "mopidy_jellyfin" ];

  meta = {
    description = "Mopidy extension for playing audio files from Jellyfin";
    homepage = "https://github.com/jellyfin/mopidy-jellyfin";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.pstn ];
  };
})
