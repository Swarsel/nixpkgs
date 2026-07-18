{
  lib,
  stdenv,
  fetchFromGitHub,
  openssl,
  pcsclite,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "age-plugin-yubikey";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "str4d";
    repo = "age-plugin-yubikey";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RmRc71BhDv1zAyuQ85sK/EXH+Wz6dAA5LqLtgmVWQ4c=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ pcsclite ];

  cargoHash = "sha256-7NAQyDelk8m1bTNi6ZrkL1S2h+/OjXQODkjbHfykF4Y=";

  meta = {
    description = "YubiKey plugin for age";
    homepage = "https://github.com/str4d/age-plugin-yubikey";
    changelog = "https://github.com/str4d/age-plugin-yubikey/blob/${finalAttrs.src.rev}/CHANGELOG.md";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [
      kranzes
      vtuan10
      adamcstephens
    ];

    mainProgram = "age-plugin-yubikey";
  };
})
