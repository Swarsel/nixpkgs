{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  mecab,
  plac,
  platformdirs,
  requests,
  setuptools-scm,
  tqdm,
  wasabi,
}:

buildPythonPackage rec {
  pname = "unidic";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "polm";
    repo = "unidic-py";
    tag = "v${version}";
    hash = "sha256-srhQDXGgoIMhYuCbyQB3kF4LrODnoOqLbjBQMvhPieY=";
  };

  patches = [ ./fix-download-directory.patch ];

  postPatch = ''
    substituteInPlace setup.cfg \
      --replace "wasabi>=0.6.0,<1.0.0" "wasabi"
  '';

  nativeBuildInputs = [
    cython
    mecab
    setuptools-scm
  ];

  propagatedBuildInputs = [
    requests
    tqdm
    wasabi
    plac
    platformdirs
  ];

  # no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "unidic" ];

  meta = {
    description = "Contemporary Written Japanese dictionary";
    homepage = "https://github.com/polm/unidic-py";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
