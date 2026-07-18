{
  lib,
  fetchFromGitHub,
  bluez,
  boost,
  buildPythonPackage,
  fetchpatch,
  glib,
  # build
  pkg-config,
  python,
  replaceVars,
  setuptools,
}:

buildPythonPackage rec {
  pname = "gattlib";
  version = "20210616";

  src = fetchFromGitHub {
    owner = "oscaracena";
    repo = "pygattlib";
    rev = "v.${version}";
    hash = "sha256-n3D9CWKvgw4FYmbvsfhaHN963HARBG0p4CcZBC8Gkb0=";
  };

  patches = [
    # Fix build for Python 3.13
    (fetchpatch {
      hash = "sha256-/Y/CZNdN/jcxWroqRfdCH2rPUxZUbug668MIAow0scs=";
      url = "https://github.com/oscaracena/pygattlib/commit/73a73b71cfc139e1e0a08816fb976ff330c77ea5.patch";
    })
    (replaceVars ./setup.patch {
      boost_version =
        let
          pythonVersion = with lib.versions; "${major python.version}${minor python.version}";
        in
        "boost_python${pythonVersion}";
    })
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    bluez
    boost
    glib
  ];

  # has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "gattlib" ];

  meta = {
    description = "Python library to use the GATT Protocol for Bluetooth LE devices";
    homepage = "https://github.com/oscaracena/pygattlib";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
