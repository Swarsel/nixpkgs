{
  lib,
  buildPythonPackage,
  fetchPypi,
  nix-update-script,
  numpy,
  patchelfUnstable,
  python,
  pyyaml,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "hebi-py";
  version = "2.7.9";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-7B0oxG1CVDTUVDFTJpuYvaCj+HnCL/2zmsD33W4nTLs=";
    pname = "hebi-py";
  };

  strictDeps = true;
  doCheck = false; # no tests

  postFixup = ''
    for lib in $out/${python.sitePackages}/hebi/lib/linux_x86_64/libhebi.so*; do
      patchelf --clear-execstack "$lib"
    done
  '';

  __structuredAttrs = true;

  build-system = [
    setuptools
    patchelfUnstable # Depends on --clear-execstack which is not in any tagged release yet
  ];

  dependencies = [
    numpy
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "hebi" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Python library for the Hebi Robotics API";
    homepage = "https://docs.hebi.us/";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ pandapip1 ];
    platforms = [ "x86_64-linux" ];
  };
})
