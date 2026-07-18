{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
  requests,
  vcrpy,
}:
buildPythonPackage rec {
  pname = "lrclibapi";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "Dr-Blank";
    repo = "lrclibapi";
    tag = "v${version}";
    hash = "sha256-K5wO3BexftnWe48loaW8TjySQvh2X+X3GSmG5qg+BGc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    vcrpy
  ];

  build-system = [
    poetry-core
  ];

  dependencies = [
    requests
  ];

  pyproject = true;

  pythonImportsCheck = [
    "lrclib"
  ];

  meta = {
    description = "Python wrapper for downloading synced lyrics from the lrclib.net api";
    homepage = "https://github.com/Dr-Blank/lrclibapi";
    changelog = "https://github.com/Dr-Blank/lrclibapi/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ DataHearth ];
  };
}
