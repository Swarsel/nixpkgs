{
  lib,
  buildPythonPackage,
  libgpiod,
  setuptools,
}:
buildPythonPackage {
  inherit (libgpiod) version src;
  pname = "gpiod";
  buildInputs = [ libgpiod ];

  preConfigure = ''
    cd bindings/python
  '';

  # Requires libgpiod built with --enable-tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "gpiod" ];

  meta = {
    description = "Python bindings for libgpiod";
    homepage = "https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/about/";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ lopsided98 ];
  };
}
