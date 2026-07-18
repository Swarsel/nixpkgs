{
  lib,
  buildPythonPackage,
  fetchPypi,
  lxml,
  python-dateutil,
}:

buildPythonPackage rec {
  pname = "feedgen";
  version = "1.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-2b1Rw7XpVqKlKZjDcIxNLHKfL8wxEYjh5dO5cmOTVGo=";
  };

  propagatedBuildInputs = [
    python-dateutil
    lxml
  ];

  # No tests in archive
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Python module to generate ATOM feeds, RSS feeds and Podcasts";
    homepage = "https://github.com/lkiesow/python-feedgen";

    license = with lib.licenses; [
      bsd2
      lgpl3
    ];

    maintainers = with lib.maintainers; [ casey ];
    downloadPage = "https://github.com/lkiesow/python-feedgen/releases";
  };
}
