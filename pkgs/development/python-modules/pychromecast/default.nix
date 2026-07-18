{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  casttube,
  protobuf,
  setuptools,
  zeroconf,
}:

buildPythonPackage rec {
  pname = "pychromecast";
  version = "14.0.10";

  src = fetchFromGitHub {
    owner = "home-assistant-libs";
    repo = "pychromecast";
    tag = version;
    hash = "sha256-m9rucHSiApT0Xqkf4sjVRehcGGgvbaoGgbT/s3SLxKI=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
       --replace-fail "setuptools>=65.6,<83.0" setuptools \
       --replace-fail "wheel>=0.37.1,<0.47.0" wheel
  '';

  # no tests available
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    casttube
    protobuf
    zeroconf
  ];

  pyproject = true;
  pythonImportsCheck = [ "pychromecast" ];

  meta = {
    description = "Library for Python to communicate with the Google Chromecast";
    homepage = "https://github.com/home-assistant-libs/pychromecast";
    changelog = "https://github.com/home-assistant-libs/pychromecast/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
