{ stdenv, nixpkgs-review }:

# nixpkgs-update: no auto update
nixpkgs-review.override {
  withDelta = true;
  withGlow = true;
  withNom = true;
  withSandboxSupport = stdenv.hostPlatform.isLinux;
}
