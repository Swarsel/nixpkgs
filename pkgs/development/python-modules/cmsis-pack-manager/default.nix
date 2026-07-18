{
  lib,
  fetchFromGitHub,
  appdirs,
  buildPythonPackage,
  cffi,
  hypothesis,
  jinja2,
  libiconv,
  pytestCheckHook,
  pyyaml,
  rustPlatform,
  unzip,
}:

buildPythonPackage rec {
  pname = "cmsis-pack-manager";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "pyocd";
    repo = "cmsis-pack-manager";
    tag = "v${version}";
    hash = "sha256-kb0VSg89qglL6Q5kx1nEN1OW1GYoccBTITtPw2/dXTY=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  buildInputs = [
    libiconv
  ];

  propagatedBuildInputs = [
    appdirs
    pyyaml
  ];

  nativeCheckInputs = [
    hypothesis
    jinja2
    pytestCheckHook
    unzip
  ];

  # remove cmsis_pack_manager source directory so that binaries can be imported
  # from the installed wheel instead
  preCheck = ''
    rm -r cmsis_pack_manager
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-yRNSFlEwFhfkSNjbFHipVZvJZ40pKbI9HhLtciws7nc=";
  };

  disabledTests = [
    # All require DNS.
    "test_pull_pdscs"
    "test_install_pack"
    "test_pull_pdscs_cli"
    "test_dump_parts_cli"
  ];

  propagatedNativeBuildInputs = [ cffi ];
  pyproject = true;

  meta = {
    description = "Rust and Python module for handling CMSIS Pack files";
    homepage = "https://github.com/pyocd/cmsis-pack-manager";
    license = lib.licenses.asl20;

    maintainers = [
    ];
  };
}
