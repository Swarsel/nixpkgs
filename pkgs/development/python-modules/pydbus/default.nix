{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pygobject3,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pydbus";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "LEW21";
    repo = "pydbus";
    tag = "v${version}";
    hash = "sha256-F1KKXG+7dWlEbToqtF3G7wU0Sco7zH5NqzlL58jyDGw=";
  };

  postPatch = ''
    substituteInPlace pydbus/_inspect3.py \
      --replace "getargspec" "getfullargspec"
  '';

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ pygobject3 ];
  doCheck = false; # requires a working dbus setup
  pyproject = true;

  pythonImportsCheck = [
    "pydbus"
    "pydbus.generic"
  ];

  meta = {
    description = "Pythonic DBus library";
    homepage = "https://github.com/LEW21/pydbus";
    license = lib.licenses.lgpl2Plus;
    maintainers = [ ];
  };
}
