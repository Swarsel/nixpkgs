{
  lib,
  stdenv,
  fetchFromGitHub,
  dbus,
  nix-update-script,
  perl,
  pkg-config,
  rustPlatform,
  testers,
  udev,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fnox";
  version = "1.30.0";

  src = fetchFromGitHub {
    owner = "jdx";
    repo = "fnox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-maG2+KBPBsZqRvs/Iddl7egs478s3IWOF+lJKQrjyjs=";
  };

  nativeBuildInputs = [
    perl
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    dbus
    udev
  ];

  cargoHash = "sha256-s3Cv7uAZlk67IiolLkFgcwonfYi9qUh8xXqyNPIPesM=";

  checkFlags = [
    # requires a D-Bus session unavailable in the sandbox
    "--skip=providers::keychain::tests::test_keychain_set_and_get"
  ];

  __structuredAttrs = true;

  passthru = {
    tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Flexible secret management tool supporting multiple providers and encryption methods";
    homepage = "https://github.com/jdx/fnox";
    changelog = "https://github.com/jdx/fnox/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      tiptenbrink
      Br1ght0ne
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
