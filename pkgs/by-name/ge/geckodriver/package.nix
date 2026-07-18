{
  lib,
  stdenv,
  fetchFromGitHub,
  libiconv,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "geckodriver";
  version = "0.37.0";

  src = fetchFromGitHub {
    owner = "mozilla";
    repo = "geckodriver";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-fXaOGdwpBbukphNvu9sONTXPAW+zMLv3roJ6j0iLdHQ=";
  };

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  cargoHash = "sha256-AZsNtdUbtly1AN4dbBHRdlJCHkfcYjjKw5EzVqHMeYs=";

  meta = {
    description = "Proxy for using W3C WebDriver-compatible clients to interact with Gecko-based browsers";
    homepage = "https://github.com/mozilla/geckodriver";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ jraygauthier ];
    mainProgram = "geckodriver";
  };
})
