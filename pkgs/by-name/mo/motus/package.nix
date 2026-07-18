{
  lib,
  stdenv,
  fetchFromGitHub,
  libxcb,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
  withClipboard ? true,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "motus";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "oleiade";
    repo = "motus";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7lFKlU9+/NvJi9NsVpve3IvzpS8OVHaH9cs/WRGjBV8=";
  };

  buildInputs = lib.optionals (withClipboard && stdenv.hostPlatform.isLinux) [ libxcb ];
  cargoHash = "sha256-0qK3omTkzVxkjFn2fIowl+sFmjF/hSHAROyge5CDdFg=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  buildAndTestSubdir = "crates/motus-cli";
  buildNoDefaultFeatures = !withClipboard;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Dead simple password generator";
    homepage = "https://github.com/oleiade/motus";
    changelog = "https://github.com/oleiade/motus/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ britter ];
    mainProgram = "motus";
  };
})
