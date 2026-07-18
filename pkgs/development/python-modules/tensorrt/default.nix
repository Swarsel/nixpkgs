{
  lib,
  stdenv,
  autoPatchelfHook,
  buildPythonPackage,
  cudaPackages,
  python,
}:
let
  inherit (cudaPackages.tensorrt)
    meta
    pname
    src
    version
    ;
  inherit (lib.versions) major minor;
  inherit (stdenv.hostPlatform) parsed;
in
buildPythonPackage {
  inherit version;
  # Make sure to add the cudaNamePrefix tag since we're not using cudaPackages.buildRedist but this is a
  # redistributable.
  pname = "${cudaPackages.cudaNamePrefix}-${pname}";

  src =
    let
      # https://peps.python.org/pep-0427/#file-name-convention
      distribution = pname;
      pythonTag = "cp${major python.version}${minor python.version}";
      abiTag = "none";
      platformTag = "${parsed.kernel.name}_${parsed.cpu.name}";
    in
    src + "/python/${distribution}-${version}-${pythonTag}-${abiTag}-${platformTag}.whl";

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    cudaPackages.tensorrt
  ];

  format = "wheel";
  pythonImportsCheck = [ "tensorrt" ];

  meta = {
    # Explicitly inherit from TensorRT's meta to avoid pulling in attributes added by stdenv.mkDerivation.
    inherit (meta)
      badPlatforms
      broken
      changelog
      downloadPage
      homepage
      license
      longDescription
      maintainers
      platforms
      sourceProvenance
      teams
      ;

    description = "Python bindings for TensorRT, a high-performance deep learning interface";
  };
}
