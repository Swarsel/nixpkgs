{
  lib,
  stdenv,
  fetchFromGitLab,
  glib,
  gpgme,
  gtk3,
  installShellFiles,
  nix-update-script,
  pkg-config,
  python3,
  rustPlatform,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "prs";
  version = "0.5.6";

  src = fetchFromGitLab {
    owner = "timvisee";
    repo = "prs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oV5i93+4+ZI1ngZX6A68vXQ3NtjChK8AzgjZC3URmBw=";
  };

  nativeBuildInputs = [
    gpgme
    installShellFiles
    pkg-config
    python3
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # fix following error on darwin sandbox mode:
    # objc/notify.h:1:9: fatal error: could not build module 'Cocoa'
    writableTmpDirAsHomeHook
  ];

  buildInputs = [
    glib
    gpgme
    gtk3
  ];

  cargoHash = "sha256-430/6Ww+PUBwyDs5vWLsMyHDEfF9wxgYZd455G5sj/w=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    for shell in bash fish zsh; do
      installShellCompletion --cmd prs --$shell <($out/bin/prs internal completions $shell --stdout)
    done
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  cargoBuildFlags = [
    "--no-default-features"
    "--features=alias,backend-gpgme,clipboard,notify,select-fzf-bin,select-skim,tomb,totp"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Secure, fast & convenient password manager CLI using GPG and git to sync";
    homepage = "https://gitlab.com/timvisee/prs";
    changelog = "https://gitlab.com/timvisee/prs/-/blob/v${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      lgpl3Only # lib
      gpl3Only # everything else
    ];

    maintainers = with lib.maintainers; [ colemickens ];
    mainProgram = "prs";
  };
})
