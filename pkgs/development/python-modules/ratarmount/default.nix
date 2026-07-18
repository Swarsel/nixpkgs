{
  lib,
  buildPythonPackage,
  fetchPypi,
  indexed-gzip,
  indexed-zstd,
  libarchive-c,
  mfusepy,
  python-xz,
  rapidgzip,
  rarfile,
  ratarmountcore,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ratarmount";
  version = "1.2.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-TwZ11KxFYqQTrk04GCk2igLI9bUYqFJU8f8I2vvnq38=";
  };

  checkPhase = ''
    runHook preCheck

    python tests/tests.py

    runHook postCheck
  '';

  build-system = [ setuptools ];

  dependencies = [
    indexed-gzip
    indexed-zstd
    libarchive-c
    mfusepy
    python-xz
    rapidgzip
    rarfile
    ratarmountcore
  ];

  pyproject = true;
  pythonRelaxDeps = [ "python-xz" ];

  meta = {
    description = "Mounts archives as read-only file systems by way of indexing";
    homepage = "https://github.com/mxmlnkn/ratarmount";
    changelog = "https://github.com/mxmlnkn/ratarmount/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mxmlnkn ];
    mainProgram = "ratarmount";
  };
}
