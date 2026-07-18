{
  lib,
  stdenv,
  fetchFromGitHub,
  # nativeBuildInputs
  gpgme,
  installShellFiles,
  # buildInputs
  libgpg-error,
  libxcb,
  nettle,
  nix-update-script,
  openssl,
  pkg-config,
  python3,
  rustPlatform,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ripasso-cursive";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "cortex";
    repo = "ripasso";
    tag = "release-${finalAttrs.version}";
    hash = "sha256-j98X/+UTea4lCtFfMpClnfcKlvxm4DpOujLc0xc3VUY=";
  };

  patches = [
    ./fix-tests.patch
  ];

  nativeBuildInputs = [
    gpgme
    installShellFiles
    pkg-config
    python3
    rustPlatform.bindgenHook
    writableTmpDirAsHomeHook
  ];

  buildInputs = [
    gpgme
    libgpg-error
    nettle
    openssl
    libxcb
  ];

  cargoHash = "sha256-4/87+SOUXLoOxd3a4Kptxa98mh/BWlEhK55uu7+Jrec=";

  checkFlags = lib.optionals stdenv.hostPlatform.isDarwin [
    # Fails in the darwin sandbox with:
    # Attempted to create a NULL object.
    # event loop thread panicked
    "--skip=pass::pass_tests::test_add_recipient_not_in_key_ring"
  ];

  postInstall = ''
    installManPage target/man-page/cursive/ripasso-cursive.1
  '';

  cargoBuildFlags = [ "-p ripasso-cursive" ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Simple password manager written in Rust";
    homepage = "https://github.com/cortex/ripasso";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ sgo ];
    platforms = lib.platforms.unix;
    mainProgram = "ripasso-cursive";
  };
})
