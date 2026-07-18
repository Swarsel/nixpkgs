{
  lib,
  buildPythonPackage,
  fetchPypi,
  imagemagick,
  matplotlib,
  setuptools,
}:

buildPythonPackage rec {
  pname = "matplotlib-sixel";
  version = "0.0.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-JXOb1/IacJV8bhDvF+OPs2Yg1tgRDOqwiAQfiSKTlew=";
  };

  postPatch = ''
    substituteInPlace sixel/sixel.py \
      --replace-fail 'Popen(["convert",' 'Popen(["${imagemagick}/bin/convert",'
  '';

  build-system = [ setuptools ];
  dependencies = [ matplotlib ];
  pyproject = true;
  pythonImportsCheck = [ "sixel" ];

  meta = {
    description = "Sixel graphics backend for matplotlib";
    homepage = "https://github.com/jonathf/matplotlib-sixel";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
