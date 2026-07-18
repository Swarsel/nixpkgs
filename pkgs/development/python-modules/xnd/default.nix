{
  lib,
  stdenv,
  buildPythonPackage,
  libndtypes,
  libxnd,
  ndtypes,
  python,
  pythonAtLeast,
  setuptools,
}:

buildPythonPackage {
  inherit (libxnd) version src meta;
  pname = "xnd";

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail \
        'include_dirs = ["libxnd", "ndtypes/python/ndtypes"] + INCLUDES' \
        'include_dirs = ["${libndtypes}/include", "${ndtypes}/include", "${libxnd}/include"]' \
      --replace-fail \
        'library_dirs = ["libxnd", "ndtypes/libndtypes"] + LIBS' \
        'library_dirs = ["${libndtypes}/lib", "${libxnd}/lib"]' \
      --replace-fail \
        'runtime_library_dirs = ["$ORIGIN"]' \
        'runtime_library_dirs = ["${libndtypes}/lib", "${libxnd}/lib"]'
  ''
  + lib.optionalString (pythonAtLeast "3.12") ''
    substituteInPlace python/xnd/util.h \
      --replace-fail '->ob_digit[i]' '->long_value.ob_digit[i]'
  '';

  buildInputs = [ libndtypes ];

  checkPhase = ''
    runHook preCheck

    pushd python
    mv xnd _xnd
    python test_xnd.py
    popd

    runHook postCheck
  '';

  postInstall = ''
    mkdir $out/include
    cp python/xnd/*.h $out/include
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    install_name_tool -add_rpath ${libxnd}/lib $out/${python.sitePackages}/xnd/_xnd.*.so
  '';

  build-system = [ setuptools ];
  dependencies = [ ndtypes ];
  pyproject = true;
}
