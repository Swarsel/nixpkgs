{
  lib,
  buildPythonPackage,
  fetchPypi,
  glib,
  pkg-config,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "bluepy";
  version = "1.3.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-KnHtr+EDVl+5kCVv82JMFlMDaoN9/JDh4yuDn4OXHOw=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ glib ];

  # tests try to access hardware
  checkPhase = ''
    $out/bin/blescan --help > /dev/null
    $out/bin/sensortag --help > /dev/null
    $out/bin/thingy52 --help > /dev/null
  '';

  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "bluepy" ];

  meta = {
    description = "Python interface to Bluetooth LE on Linux";
    homepage = "https://github.com/IanHarvey/bluepy";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ georgewhewell ];
    platforms = lib.platforms.linux;
  };
})
