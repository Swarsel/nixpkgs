{
  lib,
  buildPythonPackage,
  fetchFromSourcehut,
  # tests
  pillow,
  pytestCheckHook,
  # dependencies
  pyusb,
  # build-system
  setuptools,
  tqdm,
  zeroconf,
}:

buildPythonPackage rec {
  pname = "pyatem";
  version = "0.13.0"; # check latest version in setup.py

  src = fetchFromSourcehut {
    owner = "~martijnbraam";
    repo = "pyatem";
    rev = version;
    hash = "sha256-eEn09e+ZED4DGEWTUou9CRgazngHIXZv51CLhX9YuBI=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    pyusb
    tqdm
    zeroconf
  ];

  nativeCheckInputs = [
    pillow
    pytestCheckHook
  ];

  preCheck = ''
    TESTDIR=$(mktemp -d)
    cp -r pyatem/{test_*.py,fixtures} $TESTDIR/
    pushd $TESTDIR
  '';

  postCheck = ''
    popd
  '';

  pyproject = true;
  pythonImportsCheck = [ "pyatem" ];

  meta = {
    description = "Library for controlling Blackmagic Design ATEM video mixers";
    homepage = "https://git.sr.ht/~martijnbraam/pyatem";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
