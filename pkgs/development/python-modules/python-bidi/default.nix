{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  libiconv,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "python-bidi";
  version = "0.6.11";

  src = fetchFromGitHub {
    owner = "MeirKriheli";
    repo = "python-bidi";
    tag = "v${version}";
    hash = "sha256-sDr/i7MC3aNAzl/+cDbstS5QBdQqVtaLlG09qsl7krU=";
  };

  buildInputs = [ libiconv ];
  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    rm -rf bidi
  '';

  build-system = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-djfKvD7+JEV65xvk0AgRBUMBSWrEGcsgIh/vJh3+lJs=";
  };

  pyproject = true;

  meta = {
    description = "Pure python implementation of the BiDi layout algorithm";
    homepage = "https://github.com/MeirKriheli/python-bidi";

    license = lib.licenses.AND [
      lib.licenses.lgpl3Only
      lib.licenses.gpl3Only
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "pybidi";
  };
}
