{
  lib,
  fetchFromGitHub,
  installShellFiles,
  makeBinaryWrapper,
  nix-update-script,
  oniguruma,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "lla";
  version = "0.5.4";

  src = fetchFromGitHub {
    owner = "chaqchase";
    repo = "lla";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pNm3IBt5Wlk3TMqIehJKhEdEw6i+PY+w4IPYh4pS9Qo=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    installShellFiles
    pkg-config
  ];

  buildInputs = [
    oniguruma
  ];

  cargoHash = "sha256-gGa0NNcnUwnrBXHp609ShdmcyjjK7/dZ5T0MNYXz6z8=";
  # Do not vendor Oniguruma
  env.RUSTONIG_SYSTEM_LIBONIG = true;

  # TODO: Upstream also provides Elvish and PowerShell completions,
  # but `installShellCompletion` only has support for Bash, Zsh and Fish at the moment.
  postInstall = ''
    installShellCompletion completions/{_lla,lla{.bash,.fish}}
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  postFixup = ''
    wrapProgram $out/bin/lla \
      --add-flags "--plugins-dir $out/lib"
  '';

  cargoBuildFlags = [ "--workspace" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Blazing-fast `ls` replacement with superpowers";

    longDescription = ''
      `lla` is a modern `ls` replacement that transforms how developers interact with their filesystem.
      Built with Rust's performance capabilities and designed with user experience in mind,
      `lla` combines the familiarity of ls with powerful features like specialized views,
      Git integration, and a robust plugin system with an extensible list of plugins to add more functionality.
    '';

    homepage = "https://lla.chaqchase.com";
    changelog = "https://github.com/chaqchase/lla/blob/refs/tags/v${finalAttrs.version}/CHANGELOG.md";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ pluiedev ];
    platforms = lib.platforms.unix;
    mainProgram = "lla";
  };
})
