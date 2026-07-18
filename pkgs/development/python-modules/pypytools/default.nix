{
  lib,
  attrs,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  freezegun,
  numpy,
  py,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pypytools";
  version = "0.6.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-oUDAU+TRwLroNfQGYusAQKdRkHcazysqiDLfp77v5Sk=";
  };

  patches = [
    # Support for later Python releases, https://github.com/antocuni/pypytools/pull/2
    (fetchpatch {
      hash = "sha256-YoYRZmgueQmxRtGaeP4zEVxuA0U7TB0PmoYHHVI7ICQ=";
      name = "support-later-python.patch";
      url = "https://github.com/antocuni/pypytools/commit/c6aed496ec35a6ef7ce9e95084849eebc16bafef.patch";
    })
    # Fix ast.Num/ast.Index removal in Python 3.14, https://github.com/antocuni/pypytools/pull/5
    ./fix-ast-314.patch
  ];

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    # attrs is an implicit dependency
    attrs
    py
  ];

  nativeCheckInputs = [
    freezegun
    numpy
    py
    pytestCheckHook
  ];

  disabledTests = lib.optionals (pythonAtLeast "3.11") [
    # https://github.com/antocuni/pypytools/issues/4
    "test_clonefunc"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pypytools" ];

  meta = {
    description = "Collection of tools to use PyPy-specific features";
    homepage = "https://github.com/antocuni/pypytools";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
