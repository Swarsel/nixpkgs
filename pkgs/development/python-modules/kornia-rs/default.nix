{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  nasm,
  # tests
  numpy,
  pytestCheckHook,
  # nativeBuildInputs
  rustPlatform,
  torch,
}:

buildPythonPackage rec {
  pname = "kornia-rs";
  version = "0.1.14";

  src = fetchFromGitHub {
    owner = "kornia";
    repo = "kornia-rs";
    tag = "v${version}";
    hash = "sha256-xzJkuWhSQe5V+I4dKNoGflbt7cARewtEbTdJ3YY+cm8=";
  };

  nativeBuildInputs = [
    rustPlatform.maturinBuildHook
    rustPlatform.cargoSetupHook
    cmake # Only for dependencies.
    nasm # Only for dependencies.
  ];

  nativeCheckInputs = [
    numpy
    pytestCheckHook
    torch
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit
      pname
      version
      src
      ;

    hash = "sha256-hnvPKm0ul1IXKFtVe1j0D6ogXQ44wpDFpeWn/p5ZKeA=";
  };

  disabledTests = [
    # requires apriltag-imgs submodule
    "test_apriltag_decoder"
  ];

  dontUseCmakeConfigure = true; # We only want to use CMake to build some Rust dependencies.

  maturinBuildFlags = [
    "-m"
    "kornia-py/Cargo.toml"
  ];

  pyproject = true;

  meta = {
    description = "Python bindings to Low-level Computer Vision library in Rust";
    homepage = "https://github.com/kornia/kornia-rs";
    changelog = "https://github.com/kornia/kornia-rs/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ chpatrick ];
  };
}
