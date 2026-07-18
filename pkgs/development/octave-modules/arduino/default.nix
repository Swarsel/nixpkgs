{
  lib,
  fetchFromGitHub,
  arduino-core-unwrapped,
  buildOctavePackage,
  instrument-control,
  nix-update-script,
}:

buildOctavePackage rec {
  pname = "arduino";
  version = "0.12.3";

  src = fetchFromGitHub {
    owner = "gnu-octave";
    repo = "octave-arduino";
    tag = "release-${version}";
    sha256 = "sha256-gYoYXJwkuoI1S2SdOu6qpemlSjgAAx7N5LYwJq9ZrU8=";
  };

  propagatedBuildInputs = [
    arduino-core-unwrapped
  ];

  requiredOctavePackages = [
    instrument-control
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "release-(.*)"
    ];
  };

  meta = {
    description = "Basic Octave implementation of the matlab arduino extension, allowing communication to a programmed arduino board to control its hardware";
    homepage = "https://gnu-octave.github.io/packages/arduino/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ravenjoad ];
    name = "Octave Arduino Toolkit";
  };
}
