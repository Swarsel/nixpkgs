{
  lib,
  stdenv,
  fetchFromGitHub,
  cacert,
  installShellFiles,
  libredirect,
  openssl,
  pkg-config,
  rust-jemalloc-sys,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "oha";
  version = "1.15.0";

  src = fetchFromGitHub {
    owner = "hatoo";
    repo = "oha";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WkV4tiDjaFy0fttR7HhhqxWF2VggQfdNMLIZzxjTCOA=";
  };

  nativeBuildInputs = [
    installShellFiles
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    openssl
    rust-jemalloc-sys
  ];

  cargoHash = "sha256-KZZKV5DXABfgjXRc+BhO0AGONaKxoCNKYxTnupzvZV0=";

  env = {
    CARGO_PROFILE_RELEASE_CODEGEN_UNITS = "1";
    CARGO_PROFILE_RELEASE_LTO = "fat";
  };

  doCheck = true;

  nativeCheckInputs = [
    libredirect.hook
  ];

  checkInputs = [ cacert ];

  checkFlags = [
    "--skip=test_google"
    "--skip=test_proxy"
  ];

  preCheck = ''
    echo "nameserver 127.0.0.1" > resolv.conf
    export NIX_REDIRECTS="/etc/resolv.conf=$(realpath resolv.conf)"
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    for shell in bash fish zsh; do
      installShellCompletion --cmd oha --$shell <($out/bin/oha --completions $shell)
    done
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  meta = {
    description = "HTTP load generator inspired by rakyll/hey with tui animation";
    homepage = "https://github.com/hatoo/oha";
    changelog = "https://github.com/hatoo/oha/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jpds ];
    mainProgram = "oha";
  };
})
