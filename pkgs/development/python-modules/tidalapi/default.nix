{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  isodate,
  mpegdash,
  poetry-core,
  pyaes,
  python-dateutil,
  ratelimit,
  requests,
  typing-extensions,
}:
buildPythonPackage rec {
  pname = "tidalapi";
  version = "0.8.11";

  src = fetchFromGitHub {
    owner = "EbbLabs";
    repo = "python-tidal";
    tag = "v${version}";
    hash = "sha256-5IGMSiDwEGCnMtTARmx8Z9nfc3BaCe6z32m5j2FFBAI=";
  };

  doCheck = false; # tests require internet access

  build-system = [
    poetry-core
  ];

  dependencies = [
    requests
    python-dateutil
    mpegdash
    isodate
    ratelimit
    typing-extensions
    pyaes
  ];

  pyproject = true;

  pythonImportsCheck = [
    "tidalapi"
  ];

  meta = {
    description = "Unofficial Python API for TIDAL music streaming service";
    homepage = "https://github.com/tamland/python-tidal";
    changelog = "https://github.com/tamland/python-tidal/blob/v${version}/HISTORY.rst";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      drafolin
      drawbu
      ryand56
    ];
  };
}
