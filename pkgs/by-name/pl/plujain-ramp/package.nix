{
  lib,
  stdenv,
  fetchFromGitHub,
  lv2,
}:

stdenv.mkDerivation {
  pname = "plujain-ramp";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "Houston4444";
    repo = "plujain-ramp";
    rev = "1bc1fed211e140c7330d6035122234afe78e5257";
    sha256 = "1k7qpr8c15d623c4zqxwdklp98amildh03cqsnqq5ia9ba8z3016";
  };

  buildInputs = [
    lv2
  ];

  installFlags = [ "INSTALL_PATH=$(out)/lib/lv2" ];

  meta = {
    description = "Mono rhythmic tremolo LV2 Audio Plugin";
    homepage = "https://github.com/Houston4444/plujain-ramp";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.hirenashah ];
    platforms = lib.platforms.linux;
  };
}
