{
  lib,
  fetchFromGitHub,
  installShellFiles,
  rust-jemalloc-sys,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "yazi";
  version = "26.5.6";
  nativeBuildInputs = [ installShellFiles ];
  buildInputs = [ rust-jemalloc-sys ];
  cargoHash = "sha256-gc0uEMNJ+eCIymXK10+Swi11xuyP5cj6MbLLB/ZDgXw=";
  env.VERGEN_BUILD_DATE = "2026-05-05";
  env.VERGEN_GIT_SHA = "Nixpkgs";
  env.YAZI_GEN_COMPLETIONS = true;

  postInstall = ''
    installShellCompletion --cmd yazi \
      --nushell ./yazi-boot/completions/yazi.nu \
      --bash    ./yazi-boot/completions/yazi.bash \
      --fish    ./yazi-boot/completions/yazi.fish \
      --zsh     ./yazi-boot/completions/_yazi

    installShellCompletion --cmd ya \
      --nushell ./yazi-cli/completions/ya.nu \
      --bash    ./yazi-cli/completions/ya.bash \
      --fish    ./yazi-cli/completions/ya.fish \
      --zsh     ./yazi-cli/completions/_ya

    installManPage ../${finalAttrs.passthru.srcs.man_src.name}/yazi{.1,-config.5}

    install -Dm444 assets/yazi.desktop -t $out/share/applications
    install -Dm444 assets/logo.png $out/share/pixmaps/yazi.png
  '';

  sourceRoot = finalAttrs.passthru.srcs.code_src.name;
  srcs = builtins.attrValues finalAttrs.passthru.srcs;

  passthru.srcs = {
    code_src = fetchFromGitHub {
      hash = "sha256-sdaqZwLb+fBTg5Pd6WWfOWKCavsXWSSZrBEXuYuc8iM=";
      owner = "sxyazi";
      repo = "yazi";
      tag = "v${finalAttrs.version}";
    };

    man_src = fetchFromGitHub {
      hash = "sha256-kEVXejDg4ChFoMNBvKlwdFEyUuTcY2VuK9j0PdafKus=";
      name = "manpages"; # needed to ensure name is unique
      owner = "yazi-rs";
      repo = "manpages";
      rev = "8950e968f4a1ad0b83d5836ec54a070855068dbf";
    };
  };

  passthru.updateScript.command = [ ./update.sh ];

  meta = {
    description = "Blazing fast terminal file manager written in Rust, based on async I/O";
    homepage = "https://github.com/sxyazi/yazi";
    changelog = "https://github.com/sxyazi/yazi/blob/${finalAttrs.passthru.srcs.code_src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      eljamm
      khaneliman
      linsui
      matthiasbeyer
      uncenter
      xyenon
    ];

    mainProgram = "yazi";
  };
})
