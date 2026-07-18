{
  lib,
  buildPythonPackage,
  fetchPypi,
  iopath,
  # build inputs
  numpy,
  pillow,
  pyyaml,
  shapely,
  tabulate,
  termcolor,
  # check inputs
  torch,
  tqdm,
  yacs,
}:
let
  pname = "fvcore";
  version = "0.1.5.post20221221";
  optional-dependencies = {
    all = [ shapely ];
  };
in
buildPythonPackage {
  inherit pname version;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-8vsLuQVyrmUcEceOIEk+0ZsiQFUKfku7LW3oe90DeGA=";
  };

  propagatedBuildInputs = [
    numpy
    yacs
    pyyaml
    tqdm
    termcolor
    pillow
    tabulate
    iopath
  ];

  # TypeError: flop_count() missing 2 required positional arguments: 'model' and 'inputs'
  doCheck = false;
  nativeCheckInputs = [ torch ];
  format = "setuptools";
  optional-dependencies = optional-dependencies;
  pythonImportsCheck = [ "fvcore" ];

  meta = {
    description = "Collection of common code that's shared among different research projects in FAIR computer vision team";
    homepage = "https://github.com/facebookresearch/fvcore";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ happysalada ];
  };
}
