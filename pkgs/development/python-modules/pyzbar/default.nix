{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pillow,
  pytestCheckHook,
  setuptools,
  zbar,
}:

let
  zbar' = zbar.override {
    enableVideo = false;
    withXorg = false;
  };
in
buildPythonPackage rec {
  pname = "pyzbar";
  version = "0.1.9";

  src = fetchFromGitHub {
    owner = "NaturalHistoryMuseum";
    repo = "pyzbar";
    tag = "v${version}";
    sha256 = "8IZQY6qB4r1SUPItDlTDnVQuPs0I38K3yJ6LiPJuwbU=";
  };

  # find_library doesn't return an absolute path
  # https://github.com/NixOS/nixpkgs/issues/7307
  postPatch = ''
    substituteInPlace pyzbar/zbar_library.py \
      --replace-fail \
        "find_library('zbar')" \
        '"${lib.getLib zbar'}/lib/libzbar${stdenv.hostPlatform.extensions.sharedLibrary}"'
  '';

  buildInputs = [ zbar' ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    pillow
    numpy
  ];

  disabledTests = [
    # find_library has been replaced by a hardcoded path
    # the test fails due to find_library not called
    "test_found_non_windows"
    "test_not_found_non_windows"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyzbar" ];

  meta = {
    description = "Read one-dimensional barcodes and QR codes from Python using the zbar library";
    homepage = "https://github.com/NaturalHistoryMuseum/pyzbar";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gador ];
  };
}
