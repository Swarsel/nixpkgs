{
  lib,
  attrs,
  buildPythonPackage,
  docopt,
  fetchPypi,
  libx11,
  libxext,
  libxres,
  meson,
  meson-python,
  pillow,
  pkg-config,
  psutil,
  python-xlib,
}:

buildPythonPackage rec {
  pname = "ueberzug";
  version = "18.3.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-1Lk4E5YwEq2mUnYbIWDhzz9/CCwfXMJ11/TtJ44ugOk=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    libxres
    libxext
  ];

  doCheck = false;

  build-system = [
    meson
    meson-python
  ];

  dependencies = [
    attrs
    docopt
    pillow
    psutil
    python-xlib
  ];

  pyproject = true;
  pythonImportsCheck = [ "ueberzug" ];

  meta = {
    description = "Alternative for w3mimgdisplay";
    homepage = "https://github.com/ueber-devel/ueberzug";
    changelog = "https://github.com/ueber-devel/ueberzug/releases/tag/${version}";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "ueberzug";
  };
}
