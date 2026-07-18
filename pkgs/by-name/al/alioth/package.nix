{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "alioth";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "google";
    repo = "alioth";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ny/YrXHo4qP8NDiRNtXv843RjJKzKFuSH20ZoGp3ODQ=";
  };

  cargoHash = "sha256-eWozwXaVtR/3k7w7+tPzK1xlt9/DtvTYC+YPL/A+sU0=";
  # Checks use `debug_assert_eq!`
  checkType = "debug";
  separateDebugInfo = true;

  meta = {
    description = "Experimental Type-2 Hypervisor in Rust implemented from scratch";
    homepage = "https://github.com/google/alioth";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ astro ];

    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];

    mainProgram = "alioth";
  };
})
