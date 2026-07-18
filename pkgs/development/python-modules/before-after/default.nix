{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "before-after";
  version = "1.0.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-x9T5uLi7UgldoUxLnFnqaz9bnqn9zop7/HLsrg9aP4U=";
    pname = "before_after";
  };

  patches = [
    # drop 'mock' dependency for python >=3.3
    (fetchpatch {
      hash = "sha256-FYCpLxcOLolNPiKzHlgrArCK/QKCwzag+G74wGhK4dc=";
      url = "https://github.com/c-oreills/before_after/commit/cf3925148782c8c290692883d1215ae4d2c35c3c.diff";
    })
    (fetchpatch {
      hash = "sha256-8YJumF/U8H+hc7rLZLy3UhXHdYJmcuN+O8kMx8yqMJ0=";
      url = "https://github.com/c-oreills/before_after/commit/11c0ecc7e8a2f90a762831e216c1bc40abfda43a.diff";
    })
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "before_after" ];

  meta = {
    description = "Sugar over the Mock library to help test race conditions";
    homepage = "https://github.com/c-oreills/before_after";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
  };
})
