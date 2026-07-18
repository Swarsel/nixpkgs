{
  lib,
  fetchPypi,
  nix-update-script,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "mcuboot-imgtool";
  version = "2.4.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-7y2x2eP2K5vJQlqOhsTqchLBZPChbpI9VSUPDYdDNC4=";
    pname = "imgtool";
  };

  nativeBuildInputs = with python3Packages; [ setuptools ];

  propagatedBuildInputs = with python3Packages; [
    cbor2
    click
    cryptography
    intelhex
    pyyaml
  ];

  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "MCUboot's image signing and key management";
    homepage = "https://github.com/mcu-tools/mcuboot/tree/main/scripts";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ otavio ];
    mainProgram = "imgtool";
  };
})
