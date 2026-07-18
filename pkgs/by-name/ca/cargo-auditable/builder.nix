{
  lib,
  stdenv,
  fetchFromGitHub,
  auditable-bootstrap,
  installShellFiles,
  rustPlatform,
}:
lib.extendMkDerivation {
  constructDrv = rustPlatform.buildRustPackage.override { cargo-auditable = auditable-bootstrap; };

  extendDrvArgs =
    finalAttrs:
    {
      auditable ? true,
      cargoHash ? "",
      hash ? "",
      passthru ? { },
      pname ? "cargo-auditable",
      ...
    }:
    {
      inherit auditable pname;

      src = fetchFromGitHub {
        inherit hash;
        owner = "rust-secure-code";
        repo = "cargo-auditable";
        tag = "v${finalAttrs.version}";
      };

      nativeBuildInputs = [
        installShellFiles
      ];

      checkFlags = [
        # requires wasm32-unknown-unknown target
        "--skip=test_wasm"
        # Seems to be a bug in tests of locked vs. semver compatible packages
        # https://github.com/rust-secure-code/cargo-auditable/issues/235
        "--skip=test_proc_macro"
        "--skip=test_self_hosting"
      ]
      # TODO: Clean up on `staging`.
      ++
        lib.optionals
          (
            stdenv.hostPlatform.isMusl
            || stdenv.hostPlatform.isAarch32
            || stdenv.hostPlatform.isDarwin
            || stdenv.hostPlatform.isMsvc
          )
          [
            # Expects `linker = "rust-lld"` to work.
            "--skip=test_bare_linker"
          ];

      postInstall = ''
        installManPage cargo-auditable/cargo-auditable.1
      '';

      __structuredAttrs = true;

      passthru = passthru // {
        bootstrap = auditable-bootstrap;
      };

      meta = {
        description = "Tool to make production Rust binaries auditable";
        homepage = "https://github.com/rust-secure-code/cargo-auditable";
        changelog = "https://github.com/rust-secure-code/cargo-auditable/blob/v${finalAttrs.version}/cargo-auditable/CHANGELOG.md";

        license = with lib.licenses; [
          mit # or
          asl20
        ];

        maintainers = with lib.maintainers; [ RossSmyth ];
        mainProgram = "cargo-auditable";
        broken = stdenv.hostPlatform != stdenv.buildPlatform;
      };
    };
}
