{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uutils-diffutils";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "uutils";
    repo = "diffutils";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YZAa4A5fvW8BcaZn4xSVbSnzyoAaKKqBzpFOjnSRnc4=";
  };

  cargoHash = "sha256-jX3uuUopNaVi+XNskBUPzITlJrsVkXWR8LP7PTuwMm8=";

  checkFlags = [
    # called `Result::unwrap()` on an `Err` value: Os { code: 2, kind: NotFound, message: "No such file or directory" }
    "--skip=ed_diff::tests::test_permutations"
    "--skip=ed_diff::tests::test_permutations_reverse"
    "--skip=ed_diff::tests::test_permutations_empty_lines"
  ];

  postInstall = ''
    ln -s $out/bin/diffutils $out/bin/cmp
    ln -s $out/bin/diffutils $out/bin/diff
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/diffutils 2>/dev/null | head -1 | grep -F 'diffutils ${finalAttrs.version}'

    runHook postInstallCheck
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Drop-in replacement of diffutils in Rust";
    homepage = "https://github.com/uutils/diffutils";
    changelog = "https://github.com/uutils/diffutils/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ defelo ];
    platforms = lib.platforms.unix;
    mainProgram = "diffutils";
  };
})
