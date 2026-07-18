{
  lib,
  buildPythonPackage,
  fetchpatch,
  # optional dependencies
  numpy,
  # check inputs
  openai,
  pytestCheckHook,
  # build-system
  setuptools,
  setuptools-scm,
  # dependencies
  sqlite-vec-c, # alias for pkgs.sqlite-vec
}:

buildPythonPackage rec {
  inherit (sqlite-vec-c) pname version src;

  patches = [
    (fetchpatch {
      hash = "sha256-4/9QLKuM/1AbD8AQHwJ14rhWVYVc+MILvK6+tWwWQlw=";
      # https://github.com/asg017/sqlite-vec/pull/233
      name = "add-python-build-files.patch";
      stripLen = 1;
      url = "https://github.com/asg017/sqlite-vec/commit/c1917deb11aa79dcac32440679345b93e13b1b86.patch";
    })
    (fetchpatch {
      hash = "sha256-8dfw7zs7z2FYh8DoAxurMYCDMOheg8Zl1XGcPw1A1BM=";
      # https://github.com/asg017/sqlite-vec/pull/233
      name = "add-python-test.patch";
      stripLen = 1;
      url = "https://github.com/asg017/sqlite-vec/commit/608972c9dcbfc7f4583e99fd8de6e5e16da11081.patch";
    })
  ];

  # Change into the proper directory for building, move `extra_init.py` into its proper location,
  # and supply the path to the library.
  postPatch = ''
    cd python
    mv extra_init.py sqlite_vec/
    substituteInPlace sqlite_vec/__init__.py \
      --replace-fail "@libpath@" "${lib.getLib sqlite-vec-c}/lib/"
  '';

  nativeCheckInputs = [
    numpy
    openai
    pytestCheckHook
    sqlite-vec-c
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    sqlite-vec-c
  ];

  optional-dependencies = {
    numpy = [
      numpy
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "sqlite_vec" ];
  # The actual source root is bindings/python but the patches
  # apply to the bindings directory.
  # This is a known issue, see https://discourse.nixos.org/t/how-to-apply-patches-with-sourceroot/59727
  sourceRoot = "${src.name}/bindings";

  meta = sqlite-vec-c.meta // {
    description = "Python bindings for sqlite-vec";
    maintainers = [ lib.maintainers.sarahec ];
  };
}
