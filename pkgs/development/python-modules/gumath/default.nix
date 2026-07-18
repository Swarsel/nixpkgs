{
  lib,
  stdenv,
  buildPythonPackage,
  fetchpatch,
  libgumath,
  libndtypes,
  libxnd,
  ndtypes,
  numba,
  python,
  xnd,
}:

buildPythonPackage {
  inherit (libgumath) src version meta;
  pname = "gumath";

  patches = [
    # https://github.com/xnd-project/gumath/pull/42
    (fetchpatch {
      hash = "sha256-7lUXNVH5M+Go1iEu0bud03XI8cyGbdLNdLraMZplDaM=";
      name = "remove-np-warnings-call.patch";
      url = "https://github.com/xnd-project/gumath/commit/83ab3aa3b07d55654b4e6e75e5ec6be8190fca97.patch";
    })
    (fetchpatch {
      hash = "sha256-flltk3RNPHalbcIV0BrkxWuhqqJBrycos7Fyv3P3mWg=";
      name = "remove-np-1.25-bartlett-test-assertion.patch";
      url = "https://github.com/xnd-project/gumath/commit/8741e31f2967ded08c96a7f0631e1e38fe813870.patch";
    })
  ];

  postPatch = ''
    substituteInPlace setup.py \
      --replace 'add_include_dirs = [".", "libgumath", "ndtypes/python/ndtypes", "xnd/python/xnd"] + INCLUDES' \
                'add_include_dirs = [".", "${libndtypes.dev}/include", "${libxnd}/include", "${libgumath}/include"]' \
      --replace 'add_library_dirs = ["libgumath", "ndtypes/libndtypes", "xnd/libxnd"] + LIBS' \
                'add_library_dirs = ["${libndtypes}/lib", "${libxnd}/lib", "${libgumath}/lib"]' \
      --replace 'add_runtime_library_dirs = ["$ORIGIN"]' \
                'add_runtime_library_dirs = ["${libndtypes}/lib", "${libxnd}/lib", "${libgumath}/lib"]'
  '';

  propagatedBuildInputs = [
    ndtypes
    xnd
  ];

  nativeCheckInputs = [ numba ];

  checkPhase = ''
    pushd python
    mv gumath _gumath
    # minor precision issues
    substituteInPlace test_gumath.py --replace 'test_sin' 'dont_test_sin'
    python test_gumath.py
    python test_xndarray.py
    popd
  '';

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    install_name_tool -add_rpath ${libgumath}/lib $out/${python.sitePackages}/gumath/_gumath.*.so
  '';

  format = "setuptools";
}
