{
  lib,
  fetchFromGitHub,
  alsa-lib,
  pkg-config,
  porsmo,
  rustPlatform,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "porsmo";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "ColorCookie-dev";
    repo = "porsmo";
    rev = finalAttrs.version;
    hash = "sha256-bYPUSrGJKoNLFkIiGuXraYoaYn/HKSP8IiH3gtyWfmw=";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    alsa-lib
  ];

  cargoHash = "sha256-zkeQY0YNcKfyaWHmv1N61dBggsvFzz1fgkjXkyYK3Lg=";

  passthru.tests.version = testers.testVersion {
    package = porsmo;
  };

  meta = {
    description = "Pomodoro cli app in rust with timer and countdown";
    homepage = "https://github.com/ColorCookie-dev/porsmo";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ MoritzBoehme ];
    mainProgram = "porsmo";
  };
})
