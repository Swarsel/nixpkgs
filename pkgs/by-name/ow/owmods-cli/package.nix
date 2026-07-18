{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  libsoup_3,
  makeWrapper,
  mono,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  zstd,
  wrapWithMono ? true,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "owmods-cli";
  version = "0.15.7";

  src = fetchFromGitHub {
    owner = "ow-mods";
    repo = "ow-mod-man";
    rev = "cli_v${finalAttrs.version}";
    hash = "sha256-ohCP0VKf2jEtjZsDN5ISZ5c/EGYANvjuCPyKQcNCwyc=";
  };

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ]
  ++ lib.optional wrapWithMono makeWrapper;

  buildInputs = [
    zstd
    libsoup_3
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    openssl
  ];

  cargoHash = "sha256-oYTz7Dzdv9prHzDSSjX9PozzKToMXRW6qs8Y2dfYQ8A=";

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  postInstall = ''
    cargo xtask dist_cli
    installManPage dist/cli/man/*
    installShellCompletion --cmd owmods \
    dist/cli/completions/owmods.{bash,fish,zsh}
  ''
  + lib.optionalString wrapWithMono ''
    wrapProgram $out/bin/${finalAttrs.meta.mainProgram} --prefix PATH : '${mono}/bin'
  '';

  buildAndTestSubdir = "owmods_cli";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI version of the mod manager for Outer Wilds Mod Loader";
    homepage = "https://github.com/ow-mods/ow-mod-man/tree/main/owmods_cli";
    changelog = "https://github.com/ow-mods/ow-mod-man/releases/tag/cli_v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      bwc9876
      spoonbaker
      locochoco
    ];

    mainProgram = "owmods";
    downloadPage = "https://github.com/ow-mods/ow-mod-man/releases/tag/cli_v${finalAttrs.version}";
  };
})
