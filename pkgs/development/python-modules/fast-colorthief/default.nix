{
  lib,
  buildPythonPackage,
  cmake,
  fetchPypi,
  nix-update-script,
  numpy,
  pillow,
  setuptools,
}:

buildPythonPackage rec {
  pname = "fast-colorthief";
  version = "0.0.5";

  # No tags on github
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-yUO1vnOt2NPyldPjFMn0jbhVX8zHcKsJ2IFVugYBZa4=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail \
      "cmake_minimum_required(VERSION 2.8.12)" \
      "cmake_minimum_required(VERSION 3.10)"
    substituteInPlace pybind11/CMakeLists.txt --replace-fail \
      "cmake_minimum_required(VERSION 3.4)" \
      "cmake_minimum_required(VERSION 3.10)"
  '';

  # return to project root to locate pyproject.toml for build
  preBuild = "cd ..";

  build-system = [
    setuptools
    cmake
  ];

  dependencies = [
    pillow
    numpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "fast_colorthief" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Selection of most dominant colors in image using Modified Median Cut Quantization";
    homepage = "https://github.com/bedapisl/fast-colorthief";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
}
