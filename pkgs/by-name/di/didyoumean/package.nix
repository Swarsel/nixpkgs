{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  libxcb,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "didyoumean";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "hisbaan";
    repo = "didyoumean";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-PSEoh1OMElFJ8m4er1vBMkQak3JvLjd+oWNWA46cows=";
  };

  nativeBuildInputs = [
    installShellFiles
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    libxcb
    openssl
  ];

  cargoHash = "sha256-BASM0gBQFuJY2ze9X9HJUkiP4WrOP/inD87bVFraeAY=";
  # Clipboard doesn't exist in test environment
  doCheck = false;

  postInstall = ''
    installManPage man/dym.1
    installShellCompletion completions/dym.{bash,fish}
    installShellCompletion --zsh completions/_dym
  '';

  meta = {
    description = "CLI spelling corrector for when you're unsure";
    homepage = "https://github.com/hisbaan/didyoumean";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      evanjs
      wegank
    ];

    mainProgram = "dym";
  };
})
