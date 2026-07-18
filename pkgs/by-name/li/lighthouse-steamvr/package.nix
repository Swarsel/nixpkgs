{
  lib,
  fetchFromGitHub,
  dbus,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "Lighthouse";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "ShayBox";
    repo = "Lighthouse";
    rev = finalAttrs.version;
    hash = "sha256-Ai+d7BKA1o98iOhQ7VXltnWHW/knw122xLZHhFM6gZ0=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dbus ];
  cargoHash = "sha256-+5fxqWq7akICVmDa8Lc6M8laEAWrrEyg4uCFLoCNRpo=";

  meta = {
    description = "VR Lighthouse power state management";
    homepage = "https://github.com/ShayBox/Lighthouse";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bddvlpr ];
    mainProgram = "lighthouse";
  };
})
