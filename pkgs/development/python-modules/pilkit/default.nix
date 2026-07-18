{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mock,
  pillow,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pilkit";
  version = "3.0";

  src = fetchFromGitHub {
    owner = "matthewwithanm";
    repo = "pilkit";
    tag = version;
    hash = "sha256-NmD9PFCkz3lz4AnGoQUpkt35q0zvDVm+kx7lVDFBcHk=";
  };

  postPatch = ''
    substituteInPlace pilkit/processors/resize.py \
      --replace "Image.ANTIALIAS" "Image.Resampling.LANCZOS"
  '';

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ pillow ];

  nativeCheckInputs = [
    mock
    pytestCheckHook
    pytest-cov-stub
  ];

  pyproject = true;
  pythonImportsCheck = [ "pilkit" ];

  meta = {
    description = "Collection of utilities and processors for the Python Imaging Library";
    homepage = "https://github.com/matthewwithanm/pilkit/";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
