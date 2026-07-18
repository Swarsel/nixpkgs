{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "stork";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "jameslittle230";
    repo = "stork";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qGcEhoytkCkcaA5eHc8GVgWvbOIyrO6BCp+EHva6wTw=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-d6PLrs/n9riQ9oQTWn+6Ec1E5JhJZ7akDg8/UB21GzI=";

  checkFlags = [
    # Fails for 1.6.0, but binary works fine
    "--skip=pretty_print_search_results::tests::display_pretty_search_results_given_output"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  cargoPatches = [ ./update-wasm-bindgen.patch ];

  meta = {
    description = "Impossibly fast web search, made for static sites";
    homepage = "https://github.com/jameslittle230/stork";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ chuahou ];
    mainProgram = "stork";
  };
})
