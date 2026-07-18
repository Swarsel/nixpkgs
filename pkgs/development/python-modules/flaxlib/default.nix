{
  lib,
  buildPythonPackage,
  # nativeBuildInputs
  cmake,
  flax,
  # build-system
  nanobind,
  ninja,
  pkg-config,
  python,
  scikit-build-core,
  tomlq,
}:

buildPythonPackage rec {
  inherit (flax) src;
  pname = "flaxlib";
  version = "0.0.1";

  postPatch = ''
    expected_version="$version"
    actual_version=$(${lib.getExe tomlq} --raw --file pyproject.toml "project.version")

    if [ "$actual_version" != "$expected_version" ]; then
      echo -e "\n\tERROR:"
      echo -e "\tThe version of the flaxlib python package ($expected_version) does not match the one in its pyproject.toml file ($actual_version)"
      echo -e "\tPlease update the version attribute of the nix python3Packages.flaxlib package."
      exit 1
    fi
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  env.CMAKE_PREFIX_PATH = "${nanobind}/${python.sitePackages}/nanobind";
  # This package does not have tests (yet ?)
  doCheck = false;

  build-system = [
    nanobind
    ninja
    scikit-build-core
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "flaxlib" ];
  sourceRoot = "${src.name}/flaxlib_src";

  passthru = {
    inherit (flax) updateScript;
  };

  meta = {
    description = "Rust library used internally by flax";
    homepage = "https://github.com/google/flax/tree/main/flaxlib";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
