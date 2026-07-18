{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  callPackage,
  libffi,
  nix-update-script,
  protobuf,
  rustPlatform,
  librusty_v8 ? callPackage ./librusty_v8.nix { },
}:
buildPythonPackage rec {
  pname = "vl-convert-python";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "vega";
    repo = "vl-convert";
    tag = "v${version}";
    hash = "sha256-W23cau2VzpvfO6DRa/40UVv4j8AbsNLfAfDaMkTyj6w=";
  };

  patches = [ ./libffi-sys-system-feature.patch ];
  nativeBuildInputs = [ protobuf ];
  buildInputs = [ libffi ];
  env.RUSTY_V8_ARCHIVE = librusty_v8;

  build-system = [
    rustPlatform.maturinBuildHook
    rustPlatform.cargoSetupHook
  ];

  buildAndTestSubdir = "vl-convert-python";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-P228JMS5K0TbZYyPgKhIbZ1NviwO1jHO5dClFYerNbI=";
  };

  pyproject = true;
  pythonImportsCheck = [ "vl_convert" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "vl-convert-python@(.*)"
    ];
  };

  meta = {
    description = "Utilities for converting Vega-Lite specs from the command line and Python";
    homepage = "https://github.com/vega/vl-convert";
    changelog = "https://github.com/vega/vl-convert/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
