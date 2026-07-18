{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  apple-sdk_15,
  jq,
  libiconv,
  nix-update-script,
  pkg-config,
  runCommand,
  rustPlatform,
  versionCheckHook,
}:

let
  # ccusage embeds the LiteLLM model-pricing table at build time. Its build
  # script otherwise downloads this file from the network, which fails in the
  # sandbox. Upstream pins the data via a flake input and points
  # CCUSAGE_PRICING_JSON_PATH at it; mirror that exact revision here so the
  # build is offline and reproducible (see package.nix + flake.lock in the
  # upstream repo at tag v20.0.6). Bump this revision together with the package
  # version; nix-update only refreshes the src and cargo hashes.
  litellmPricing = fetchurl {
    hash = "sha256-zJa6H2EwP9s+hMVs78Y+hwo4UX1dHRtvX5J3MdGh5aI=";
    url = "https://raw.githubusercontent.com/BerriAI/litellm/f27df8d516802ce4c1b32973992154fe83b851cf/model_prices_and_context_window.json";
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ccusage";
  version = "20.0.6";

  src = fetchFromGitHub {
    owner = "ccusage";
    repo = "ccusage";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uf/FlPprxx4jh74YwjmYMtoIHpTkKrWTLetbNoYiFv4=";
  };

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk_15
    libiconv
  ];

  cargoHash = "sha256-izA2Gs5nPmt0zn6/e1xM80vyyQHYKGEUDpUFRpyFiB8=";
  env.CCUSAGE_PRICING_JSON_PATH = "${litellmPricing}";
  # Upstream disables the test suite in its own Nix build; parts of it rely on
  # network access and live pricing data. versionCheckHook still exercises the
  # built binary below.
  doCheck = false;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  buildAndTestSubdir = "rust";

  # Build only the ccusage binary out of the multi-crate workspace.
  cargoBuildFlags = [
    "-p"
    "ccusage"
    "--bin"
    "ccusage"
  ];

  # The Cargo workspace lives in rust/, not at the repo root.
  cargoRoot = "rust";

  passthru = {
    tests = {
      # With no agent data on disk, ccusage must still emit a valid, empty JSON
      # report. --offline keeps it from reaching the network, exercising the
      # pricing table baked in at build time. This guards the data discovery,
      # JSON serialization, and offline-pricing paths without needing fixtures.
      smoke =
        runCommand "ccusage-smoke-test"
          {
            nativeBuildInputs = [
              finalAttrs.finalPackage
              jq
            ];
          }
          ''
            export HOME="$(mktemp -d)"
            ccusage daily --json --offline > report.json
            jq -e '.daily == [] and .totals.totalTokens == 0' report.json
            touch "$out"
          '';
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Analyze coding agent CLI token usage and costs from local data";
    homepage = "https://github.com/ccusage/ccusage";
    changelog = "https://github.com/ccusage/ccusage/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ thrix ];
    mainProgram = "ccusage";
  };
})
