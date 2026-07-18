{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pkgs,
  setuptools,
}:

buildPythonPackage rec {
  pname = "hwdata";
  version = "2.4.3-1";

  src = fetchFromGitHub {
    owner = "xsuchy";
    repo = "python-hwdata";
    tag = "python-hwdata-${version}";
    hash = "sha256-5bcdyCGv1sM8HThoSsvJe68LprDq0kI801F/aTH5FVs=";
  };

  nativeBuildInputs = [ setuptools ];
  doCheck = false; # no tests

  patchPhase = ''
    substituteInPlace hwdata.py --replace "/usr/share/hwdata" "${pkgs.hwdata}/share/hwdata"
  '';

  pyproject = true;
  pythonImportsCheck = [ "hwdata" ];

  meta = {
    description = "Python bindings to hwdata";
    homepage = "https://github.com/xsuchy/python-hwdata";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ lurkki ];
  };
}
