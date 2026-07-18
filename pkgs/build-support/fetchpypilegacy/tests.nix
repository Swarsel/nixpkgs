{ fetchPypiLegacy, testers, ... }:
{
  # Tests that we can send custom headers with spaces in them
  fetchSimple = testers.invalidateFetcherByDrvHash fetchPypiLegacy {
    pname = "requests";
    file = "requests-2.31.0.tar.gz";
    hash = "sha256-lCxadY+Y15Dq7Ropy27vx/+w0c968Fw9J5Flbb1q0eE=";
    url = "https://pypi.org/simple";
  };
}
