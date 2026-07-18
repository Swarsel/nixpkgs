{
  lib,
  buildPythonPackage,
  fetchPypi,
}:
buildPythonPackage rec {
  pname = "pymeta3";
  version = "0.5.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-GL2jJtmpu/WHv8DuC8loZJZNeLBnKIvPVdTZhoHQW8s=";
    pname = "PyMeta3";
  };

  doCheck = false; # Tests do not support Python3
  format = "setuptools";
  pythonImportsCheck = [ "pymeta" ];

  meta = {
    description = "Pattern-matching language based on OMeta for Python 3 and 2";
    homepage = "https://github.com/wbond/pymeta3";
    changelog = "https://github.com/wbond/pymeta3/releases/tag/${version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jfly
      matusf
    ];
  };
}
