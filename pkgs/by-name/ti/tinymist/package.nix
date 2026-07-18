{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  installShellFiles,
  nix-update-script,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  vscode-extensions,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tinymist";
  # Please update the corresponding vscode extension when updating
  # this derivation.
  version = "0.15.2";

  src = fetchFromGitHub {
    owner = "Myriad-Dreamin";
    repo = "tinymist";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wNSMjfU3upsqKQQUYx76iFGC+5ghcErlxy65ZJ/LvHk=";
  };

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  cargoHash = "sha256-NEvINvHMD9tVG9kyj84AC8DEAbR0ndjkCHpwR4OD6YA=";

  checkFlags = [
    "--skip=e2e"

    # Require internet access
    "--skip=docs::package::tests::cetz"
    "--skip=docs::package::tests::fletcher"
    "--skip=docs::package::tests::tidy"
    "--skip=docs::package::tests::touying"

    # Tests are flaky for unclear reasons since the 0.12.3 release
    # Reported upstream: https://github.com/Myriad-Dreamin/tinymist/issues/868
    "--skip=analysis::expr_tests::scope"
    "--skip=analysis::post_type_check_tests::test"
    "--skip=analysis::type_check_tests::test"
    "--skip=completion::tests::test_pkgs"
    "--skip=folding_range::tests::test"
    "--skip=goto_definition::tests::test"
    "--skip=hover::tests::test"
    "--skip=inlay_hint::tests::smart"
    "--skip=prepare_rename::tests::prepare"
    "--skip=references::tests::test"
    "--skip=rename::tests::test"
    "--skip=semantic_tokens_full::tests::test"

    # Return "No compatible device found" when testing preview
    "--skip=doc::tests::diff_v1_preview_frame_paints_generated_page"
    "--skip=doc::tests::full_current_preview_frame_paints_generated_page_after_reset"
    "--skip=doc::tests::page_canvas_exposes_synthetic_accesskit_link_nodes"
    "--skip=doc::tests::page_canvas_exposes_synthetic_accesskit_text_runs"
    "--skip=doc::tests::page_canvas_paints_selection_overlay_above_scene"
    "--skip=doc::tests::page_canvas_paints_supplied_white_background"
    "--skip=doc::tests::page_canvas_selects_and_copies_text"
    "--skip=doc::tests::page_canvas_uses_pointer_cursor_over_links"
  ];

  postInstall = lib.optionalString (stdenv.hostPlatform.emulatorAvailable buildPackages) (
    let
      emulator = stdenv.hostPlatform.emulator buildPackages;
    in
    ''
      installShellCompletion --cmd tinymist \
        --bash <(${emulator} $out/bin/tinymist completion bash) \
        --fish <(${emulator} $out/bin/tinymist completion fish) \
        --zsh <(${emulator} $out/bin/tinymist completion zsh)
    ''
  );

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;
  versionCheckProgramArg = "-V";

  passthru = {
    tests = {
      vscode-extension = vscode-extensions.myriad-dreamin.tinymist;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Integrated language service for Typst";
    homepage = "https://github.com/Myriad-Dreamin/tinymist";
    changelog = "https://github.com/Myriad-Dreamin/tinymist/blob/v${finalAttrs.version}/editors/vscode/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      GaetanLepage
      lampros
    ];

    mainProgram = "tinymist";
  };
})
