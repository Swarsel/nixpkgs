{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  cryptography,
  ecdsa,
  fido2,
  flit,
  intelhex,
  pyserial,
  pyusb,
  requests,
}:

buildPythonPackage (finalAttrs: {
  pname = "solo-python";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "solokeys";
    repo = "solo-python";
    tag = finalAttrs.version;
    hash = "sha256-XVPYr7JwxeZfZ68+vQ7a7MNiAfJ2bvMbM3R1ryVJ+OU=";
  };

  preBuild = ''
    export HOME=$TMPDIR
  '';

  build-system = [ flit ];

  dependencies = [
    click
    cryptography
    ecdsa
    fido2
    intelhex
    pyserial
    pyusb
    requests
  ];

  pyproject = true;

  pythonImportsCheck = [
    "solo"
    "solo.cli"
    "solo.commands"
    "solo.fido2"
    "solo.operations"
  ];

  meta = {
    description = "Python tool and library for SoloKeys Solo 1";
    homepage = "https://github.com/solokeys/solo1-cli";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ wucke13 ];
    # not compatible with fido2 >= 1.0.0
    # https://github.com/solokeys/solo1-cli/issues/157
    broken = lib.versionAtLeast fido2.version "1.0.0";
  };
})
