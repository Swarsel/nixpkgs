{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "affine";
  version = "2.4.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ok2BjWqDbBMZdtIvjCe408oy0K9kwdjSnet7r6TaHuo=";
  };

  nativeBuildInputs = [ flit-core ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;

  meta = {
    description = "Matrices describing affine transformation of the plane";
    homepage = "https://github.com/rasterio/affine";
    changelog = "https://github.com/rasterio/affine/blob/${version}/CHANGES.txt";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
