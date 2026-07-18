{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  installShellFiles,
  nix-update-script,
  openssl,
  pkg-config,
  protobuf,
  rustPlatform,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "moon";
  version = "2.3.2";

  src = fetchFromGitHub {
    owner = "moonrepo";
    repo = "moon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Nc3J6s6+Go73lOnveH7agT80y9PVqLZw+x22vvi2mcg=";
  };

  nativeBuildInputs = [
    pkg-config
    protobuf
    installShellFiles
    writableTmpDirAsHomeHook
  ];

  buildInputs = [ openssl ];
  cargoHash = "sha256-+pmn9+7VNQyggoTmlhZ7s9vTnhSDWp5rqnFFbyLAfMk=";

  env = {
    OPENSSL_NO_VENDOR = 1;
    RUSTFLAGS = "-C strip=symbols";
  };

  # Some tests fail, because test using internet connection and install NodeJS by example
  doCheck = false;

  postInstall = lib.optionalString (stdenv.hostPlatform.emulatorAvailable buildPackages) (
    let
      emulator = stdenv.hostPlatform.emulator buildPackages;
    in
    ''
      installShellCompletion --cmd moon \
        --bash <(${emulator} $out/bin/moon completions --shell bash) \
        --fish <(${emulator} $out/bin/moon completions --shell fish) \
        --zsh <(${emulator} $out/bin/moon completions --shell zsh)
    ''
  );

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Task runner and repo management tool for the web ecosystem, written in Rust";
    homepage = "https://github.com/moonrepo/moon";
    changelog = "https://github.com/moonrepo/moon/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ flemzord ];
    mainProgram = "moon";
  };
})
