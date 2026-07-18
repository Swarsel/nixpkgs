{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "eludris";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "eludris";
    repo = "eludris";
    rev = "v${finalAttrs.version}";
    hash = "sha256-TVYgimkGUSITB3IaMlMd10PWomqyJRvONvJwiW85U4M=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-JpXjnkZHz12YxgTSqTcWdQTkrMugP7ZGw48145BeBZk=";

  cargoBuildFlags = [
    "--package"
    "eludris"
  ];

  cargoTestFlags = [
    "--package"
    "eludris"
  ];

  meta = {
    description = "Simple CLI to help you with setting up and managing your Eludris instance";
    homepage = "https://github.com/eludris/eludris/tree/main/cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ooliver1 ];
    mainProgram = "eludris";
  };
})
