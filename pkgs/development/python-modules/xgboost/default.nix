{
  stdenv,
  buildPythonPackage,
  cmake,
  hatchling,
  numpy,
  python,
  scipy,
  xgboost,
}:

let
  libExtension = stdenv.hostPlatform.extensions.sharedLibrary;
  libName = "libxgboost${libExtension}";
  libPath = "${xgboost}/lib/${libName}";
in
buildPythonPackage {
  inherit (xgboost) version src meta;
  pname = "xgboost";

  postPatch = ''
    cd python-package
  '';

  nativeBuildInputs = [
    cmake
    hatchling
  ];

  buildInputs = [ xgboost ];

  propagatedBuildInputs = [
    numpy
    scipy
  ];

  # test setup tries to download test data with no option to disable
  # (removing sklearn from nativeCheckInputs causes all previously enabled tests to be skipped)
  # and are extremely cpu intensive anyway
  doCheck = false;

  # During the build libxgboost.so is copied to its current location
  # Replacing it with a symlink to the original
  postInstall =
    let
      libOutPath = "$out/${python.sitePackages}/xgboost/lib/${libName}";
    in
    ''
      rm "${libOutPath}"
      ln -s "${libPath}" "${libOutPath}"
    '';

  __darwinAllowLocalNetworking = true;
  dontUseCmakeConfigure = true;

  # Place libxgboost.so where the build will look for it
  # to avoid triggering the compilation of the library
  prePatch = ''
    mkdir -p lib
    ln -s ${libPath} lib/
  '';

  pyproject = true;
  pythonImportsCheck = [ "xgboost" ];

  pythonRemoveDeps = [
    "nvidia-nccl-cu12"
  ];
}
