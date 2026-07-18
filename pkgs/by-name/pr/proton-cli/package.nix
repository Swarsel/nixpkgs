{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  gtk3,
  installShellFiles,
  nix-update-script,
  pkg-config,
  versionCheckHook,
  webkitgtk_4_1,
}:

buildGoModule (finalAttrs: {
  pname = "proton-cli";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "roman-16";
    repo = "proton-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0IVWoDUHXvJusFceerlz5DgifFme9PN/NaAdwwwkCK4=";
  };

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    webkitgtk_4_1
    gtk3
  ];

  vendorHash = "sha256-H4q7b+NfiktjWRyStV9/lXF9fuAkApepq6l6CNV/5co=";

  preBuild = ''
    bash scripts/build-hv-helpers.sh
  '';

  postInstall = ''
    installShellCompletion --cmd proton-cli \
      --bash <($out/bin/proton-cli completion bash) \
      --fish <($out/bin/proton-cli completion fish) \
      --zsh  <($out/bin/proton-cli completion zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/roman-16/proton-cli/internal/cli.version=${finalAttrs.version}"
  ];

  overrideModAttrs = _: {
    preBuild = null;
  };

  subPackages = [ "." ];
  tags = [ "embed_hv" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Unofficial command-line client for the Proton suite (Mail, Drive, Calendar, Contacts, Pass)";
    homepage = "https://github.com/roman-16/proton-cli";
    changelog = "https://github.com/roman-16/proton-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ roman-16 ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "proton-cli";
  };
})
