{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dask,
  matplotlib,
  pint,
  pooch,
  pytestCheckHook,
  regex,
  rich,
  scipy,
  setuptools,
  setuptools-scm,
  shapely,
  xarray,
}:

buildPythonPackage (finalAttrs: {
  pname = "cf-xarray";
  version = "0.11.3";

  src = fetchFromGitHub {
    owner = "xarray-contrib";
    repo = "cf-xarray";
    tag = "v${finalAttrs.version}";
    hash = "sha256-njwK8wJH0YKzA7Lq8J0gBvAzNJa24XncF7IB9Dy6Lys=";
  };

  nativeCheckInputs = [
    dask
    pytestCheckHook
    scipy
  ]
  ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);

  build-system = [
    setuptools
    setuptools-scm
    xarray
  ];

  dependencies = [ xarray ];

  disabledTestPaths = [
    # Tests require network access
    "cf_xarray/tests/test_accessor.py"
    "cf_xarray/tests/test_groupers.py"
    "cf_xarray/tests/test_helpers.py"
  ];

  optional-dependencies = {
    all = [
      matplotlib
      pint
      pooch
      regex
      rich
      shapely
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "cf_xarray" ];

  meta = {
    description = "Accessor for xarray objects that interprets CF attributes";
    homepage = "https://github.com/xarray-contrib/cf-xarray";
    changelog = "https://github.com/xarray-contrib/cf-xarray/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
