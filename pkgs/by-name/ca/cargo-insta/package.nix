{
  lib,
  fetchFromGitHub,
  runtimeShell,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-insta";
  version = "1.47.2";

  src = fetchFromGitHub {
    owner = "mitsuhiko";
    repo = "insta";
    tag = finalAttrs.version;
    hash = "sha256-BQuc/YCUM61Lq0hPF4foETUCC/oTSVwTY4RK+WuRnac=";
  };

  postPatch = ''
    substituteInPlace cargo-insta/tests/functional/test_runner_fallback.rs \
      --replace-fail '#!/bin/bash' '#!${runtimeShell}'
  '';

  cargoHash = "sha256-5YnsLfCM64gPlQu9qr7daCdFSZA80PpQVfYE9h237h4=";

  checkFlags = [
    # Depends on `rustfmt` and does not matter for packaging.
    "--skip=utils::test_format_rust_expression"
    # Requires networking
    "--skip=test_force_update_snapshots"

    "--skip=test_ignored_snapshots"
    "--skip=workspace::test_insta_workspace_root"
    "--skip=env::test_get_cargo_workspace_manifest_dir"
  ];

  meta = {
    description = "Cargo subcommand for snapshot testing";
    homepage = "https://github.com/mitsuhiko/insta";
    changelog = "https://github.com/mitsuhiko/insta/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      oxalica
      matthiasbeyer
      figsoda
    ];

    mainProgram = "cargo-insta";
  };
})
