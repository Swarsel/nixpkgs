{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lrzsz,
  pytest,
  setuptools,
  which,
}:

buildPythonPackage (finalAttrs: {
  pname = "xmodem";
  version = "0.4.7";

  src = fetchFromGitHub {
    owner = "tehmaze";
    repo = "xmodem";
    tag = finalAttrs.version;
    hash = "sha256-kwPA/lYiv6IJSKGRuH13tBofZwp19vebwQniHK7A/i8=";
  };

  nativeCheckInputs = [
    pytest
    which
    lrzsz
  ];

  checkPhase = ''
    pytest
  '';

  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "xmodem" ];

  meta = {
    description = "Pure python implementation of the XMODEM protocol";
    homepage = "https://github.com/tehmaze/xmodem";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ emantor ];
  };
})
