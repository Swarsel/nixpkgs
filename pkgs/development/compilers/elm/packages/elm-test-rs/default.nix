{
  lib,
  stdenv,
  fetchFromGitHub,
  openssl,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "elm-test-rs";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "mpizenberg";
    repo = "elm-test-rs";
    tag = "v${version}";
    hash = "sha256-RP0VTYMrQ8I/Szi1TFcYHmWpdDh1F1jAhWDYlYVoqyM=";
  };

  buildInputs = lib.optionals (!stdenv.hostPlatform.isDarwin) [ openssl ];
  cargoHash = "sha256-BrWN4rXTFHXj5aDvdn55ThSAF+NqMbUg7LnQcrapI0U=";
  # Tests perform networking and therefore can't work in sandbox
  doCheck = false;

  meta = {
    description = "Fast and portable executable to run your Elm tests";
    homepage = "https://github.com/mpizenberg/elm-test-rs";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      jpagex
      zupo
      turbomack
    ];

    mainProgram = "elm-test-rs";
  };
}
