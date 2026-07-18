{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tarssh";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "Freaky";
    repo = "tarssh";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-AoKc8VF6rqYIsijIfgvevwu+6+suOO7XQCXXgAPNgLk=";
  };

  cargoHash = "sha256-r1WwAL24Ohmf4L7UXUwmecRiMmthjpzoWOVv33bMkDk=";

  meta = {
    description = "Simple SSH tarpit inspired by endlessh";
    homepage = "https://github.com/Freaky/tarssh";
    license = [ lib.licenses.mit ];
    maintainers = with lib.maintainers; [ sohalt ];
    platforms = lib.platforms.unix;
    mainProgram = "tarssh";
  };
})
