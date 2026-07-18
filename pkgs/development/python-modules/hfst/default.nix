{
  lib,
  stdenv,
  buildPythonPackage,
  foma,
  icu,
  pkgs,
  swig,
}:

buildPythonPackage rec {
  inherit (pkgs.hfst) version src;
  pname = "hfst";

  postPatch = ''
    # omorfi-python looks for 'hfst' Python package
    sed -i 's/libhfst_swig/hfst/' setup.py;
  '';

  nativeBuildInputs = [ swig ];

  buildInputs = [
    icu
    pkgs.hfst
  ];

  # Find foma in Darwin tests
  preCheck = lib.optionalString stdenv.hostPlatform.isDarwin ''
    export DYLD_LIBRARY_PATH="${foma}/lib"
  '';

  format = "setuptools";
  setupPyBuildFlags = [ "--inplace" ];
  sourceRoot = "${src.name}/python";

  meta = {
    description = "Python bindings for HFST";
    homepage = "https://github.com/hfst/hfst";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ lurkki ];
  };
}
