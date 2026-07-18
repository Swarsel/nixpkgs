{
  lib,
  buildPythonPackage,
  fetchgit,
  pillow,
  poetry-core,
  pytest-benchmark,
  pytestCheckHook,
}:
let
  owner = "whtsky";
  repo = "pixelmatch-py";
in
buildPythonPackage rec {
  pname = "pixelmatch";
  version = "0.4.0";

  src = fetchgit {
    url = "https://github.com/whtsky/pixelmatch-py.git";
    tag = "v${version}";
    hash = "sha256-tl1y8SASS8XR3ix4DLvwi5OoIs73oxYOF9Z90jPIU4o=";
    fetchLFS = true;
  };

  nativeCheckInputs = [
    pillow
    pytest-benchmark
    pytestCheckHook
  ];

  build-system = [
    poetry-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "pixelmatch" ];

  meta = {
    description = "A pixel-level image comparison library";
    homepage = "https://github.com/whtsky/pixelmatch-py";
    changelog = "https://github.com/whtsky/pixelmatch-py/tree/v${version}#changelog";
    license = with lib.licenses; [ isc ];
    teams = [ lib.teams.geospatial ];
  };
}
