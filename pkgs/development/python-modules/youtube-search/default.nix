{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
}:

buildPythonPackage rec {
  pname = "youtube-search";
  version = "2.2.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-U5inzWXZt1qLrCfvaJ7ARKurPL+h8g0Z2wJ3ZZrHDZg=";
    pname = "youtube_search";
  };

  propagatedBuildInputs = [ requests ];
  # Tests require network connection
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "youtube_search" ];

  meta = {
    description = "Tool for searching for youtube videos to avoid using their heavily rate-limited API";
    homepage = "https://github.com/joetats/youtube_search";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ j0hax ];
  };
}
