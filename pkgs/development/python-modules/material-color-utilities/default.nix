{
  lib,
  buildPythonPackage,
  fetchPypi,
  pillow,
  regex,
}:

buildPythonPackage rec {
  pname = "material-color-utilities-python";
  version = "0.1.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-PG8C585wWViFRHve83z3b9NijHyV+iGY2BdMJpyVH64=";
  };

  propagatedBuildInputs = [
    pillow
    regex
  ];

  # No tests implemented.
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "material_color_utilities_python" ];
  pythonRelaxDeps = [ "Pillow" ];

  meta = {
    description = "Python port of material_color_utilities used for Material You colors";
    homepage = "https://pypi.org/project/material_color_utilities_python";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
