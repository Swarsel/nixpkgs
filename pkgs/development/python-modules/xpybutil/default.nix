{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pillow,
  setuptools,
  xcffib,
}:

buildPythonPackage (finalAttrs: {
  pname = "xpybutil";
  version = "0.0.6";

  # Pypi only offers a wheel
  src = fetchFromGitHub {
    owner = "BurntSushi";
    repo = "xpybutil";
    tag = finalAttrs.version;
    hash = "sha256-73bAQaGjI5w+Xb3t+ToDhn1FQgcUWa9UEpS5UhLG650=";
  };

  # no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  # pillow is a dependency in image.py which is not listed in setup.py
  dependencies = [
    pillow
    xcffib
  ];

  propagatedNativeBuildInputs = [ xcffib ];
  pyproject = true;
  pythonImportsCheck = [ "xpybutil" ];

  meta = {
    description = "Incomplete xcb-util port plus some extras";
    homepage = "https://github.com/BurntSushi/xpybutil";
    license = lib.licenses.wtfpl;
    maintainers = with lib.maintainers; [ artturin ];
  };
})
