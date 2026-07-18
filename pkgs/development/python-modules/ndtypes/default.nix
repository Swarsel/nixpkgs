{
  lib,
  stdenv,
  buildPythonPackage,
  libndtypes,
  numpy,
  python,
}:

buildPythonPackage {
  inherit (libndtypes) version src meta;
  pname = "ndtypes";

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    substituteInPlace setup.py \
      --replace 'include_dirs = ["libndtypes"]' \
                'include_dirs = ["${libndtypes.dev}/include"]' \
      --replace 'library_dirs = ["libndtypes"]' \
                'library_dirs = ["${libndtypes}/lib"]' \
      --replace 'runtime_library_dirs = ["$ORIGIN"]' \
                'runtime_library_dirs = ["${libndtypes}/lib"]'
  '';

  propagatedBuildInputs = [ numpy ];

  checkPhase = ''
    pushd python
    mv ndtypes _ndtypes
    python test_ndtypes.py
    popd
  '';

  postInstall = ''
    mkdir $out/include
    cp python/ndtypes/*.h $out/include
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    install_name_tool -add_rpath ${libndtypes}/lib $out/${python.sitePackages}/ndtypes/_ndtypes.*.so
  '';

  format = "setuptools";
}
