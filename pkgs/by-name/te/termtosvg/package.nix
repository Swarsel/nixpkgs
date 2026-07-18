{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "termtosvg";
  version = "1.1.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "1vk5kn8w3zf2ymi76l8cpwmvvavkmh3b9lb18xw3x1vzbmhz2f7d";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    lxml
    pyte
    wcwidth
  ];

  pyproject = true;
  pythonImportsCheck = [ "termtosvg" ];

  meta = {
    description = "Record terminal sessions as SVG animations";
    homepage = "https://nbedos.github.io/termtosvg/";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "termtosvg";
  };
})
