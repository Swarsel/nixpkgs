{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  humanfriendly,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "capturer";
  version = "3.0";

  src = fetchFromGitHub {
    owner = "xolox";
    repo = "python-capturer";
    rev = version;
    sha256 = "0fwrxa049gzin5dck7fvwhdp1856jrn0d7mcjcjsd7ndqvhgvjj1";
  };

  patches = [
    # https://github.com/xolox/python-capturer/pull/16
    (fetchpatch {
      hash = "sha256-NW+X6wdXMHSLswO7M7/YeIyHu+EDYTLJE/mBkqyhKUM=";
      name = "python314-compat.patch";
      url = "https://github.com/xolox/python-capturer/commit/3d0a9a040ecaa78ce2d39ec76ff5084ee7be6653.patch";
    })
  ];

  # hangs on darwin
  doCheck = !stdenv.hostPlatform.isDarwin;
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ humanfriendly ];
  pyproject = true;

  meta = {
    description = "Easily capture stdout/stderr of the current process and subprocesses";
    homepage = "https://github.com/xolox/python-capturer";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ eyjhb ];
  };
}
