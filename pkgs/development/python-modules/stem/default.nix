{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  mock,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "stem";
  version = "1.8.3";

  src = fetchFromGitHub {
    owner = "torproject";
    repo = "stem";
    tag = version;
    hash = "sha256-FK7ldpOGEQ+VYLgwL7rGSGNtD/2iz11b0YOa78zNGDk=";
  };

  patches = [
    (fetchurl {
      hash = "sha256-RTh3RVpDaNRFrSoAEfMVAO1VPWmnhdd5W+M0N9AEr24=";
      url = "https://gitlab.archlinux.org/archlinux/packaging/packages/python-stem/-/raw/729ce635a4dbf519bab0cd4195d507b0b9bf6c9a/fix-build-cryptography.patch";
    })
    (fetchurl {
      hash = "sha256-2pj5eeurGN9HC02U2gZibt8gNWHYU92tlETZlbaT35A=";
      name = "cryptography-42-compat.patch";
      url = "https://gitlab.archlinux.org/archlinux/packaging/packages/python-stem/-/raw/main/9f1fa4ac.patch";
    })
  ];

  postPatch = ''
    # https://github.com/torproject/stem/pull/155
    substituteInPlace stem/util/test_tools.py test/integ/*/*.py test/unit/*/*.py test/unit/version.py \
      --replace-quiet assertRaisesRegexp assertRaisesRegex
  '';

  nativeCheckInputs = [
    cryptography
    mock
  ];

  checkPhase = ''
    runHook preCheck

    ${python.interpreter} run_tests.py --unit

    runHook postCheck
  '';

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Controller library that allows applications to interact with Tor";
    homepage = "https://stem.torproject.org/";
    changelog = "https://github.com/torproject/stem/blob/${src.tag}/docs/change_log.rst";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "tor-prompt";
    downloadPage = "https://github.com/torproject/stem";
  };
}
