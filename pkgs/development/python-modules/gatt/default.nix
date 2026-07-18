{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dbus-python,
  pygobject3,
}:

buildPythonPackage rec {
  pname = "gatt";
  version = "0.2.6";

  src = fetchFromGitHub {
    owner = "getsenic";
    repo = "gatt-python";
    rev = version;
    hash = "sha256-GMLqQ9ojQ649hbbJB+KiQoOhiTWweOgv6zaCDzhIB5A=";
  };

  propagatedBuildInputs = [
    dbus-python
    pygobject3
  ];

  format = "setuptools";
  pythonImportsCheck = [ "gatt" ];

  meta = {
    description = "Bluetooth (Generic Attribute Profile) GATT SDK for Python";
    homepage = "https://github.com/getsenic/gatt-python/";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "gattctl";
  };
}
