{
  lib,
  fetchFromGitHub,
  fetchpatch,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "cantoolz";
  version = "3.7.0";

  src = fetchFromGitHub {
    owner = "CANToolz";
    repo = "CANToolz";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-0ROWx1CsKtjxmbCgPYZpvr37VKsEsWCwMehf0/0/cnY=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-BTQ0Io2RF8WpWlLoYfBj8IhL92FRR8ustGClt28/R8c=";
      # Import Iterable from collections.abc
      url = "https://github.com/CANToolz/CANToolz/commit/9e818946716a744b3c7356f248e24ea650791d1f.patch";
    })
    (fetchpatch {
      sha256 = "0g91hywg5q6f2qk1awgklywigclrbhh6a6mwd0kpbkk1wawiiwbc";
      # Replace time.clock() which was removed, https://github.com/CANToolz/CANToolz/pull/30
      url = "https://github.com/CANToolz/CANToolz/pull/30/commits/d75574523d3b273c40fb714532c4de27f9e6dd3e.patch";
    })
  ];

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
  ];

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    flask
    pyserial
    mido
    numpy
    bitstring
  ];

  disabledTests = [
    "test_process"
    # Sandbox issue
    "test_server"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "cantoolz"
  ];

  meta = {
    description = "Black-box CAN network analysis framework";

    longDescription = ''
      CANToolz is a framework for analysing CAN networks and devices. It
      provides multiple modules that can be chained using CANToolz's pipe
      system and used by security researchers, automotive/OEM security
      testers in black-box analysis.

      CANToolz can be used for ECU discovery, MitM testing, fuzzing, brute
      forcing, scanning or R&D, testing and validation. More can easily be
      implemented with a new module.
    '';

    homepage = "https://github.com/CANToolz/CANToolz";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "cantoolz";
  };
})
