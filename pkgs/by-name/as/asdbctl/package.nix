{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  rustPlatform,
  udev,
  udevCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "asdbctl";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "juliuszint";
    repo = "asdbctl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jDflaksnsw55RHMgamfJNRE7GwThQMYfXtLAWbOnoMw=";
  };

  nativeBuildInputs = [
    pkg-config
    udevCheckHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    udev
  ];

  cargoHash = "sha256-OPmnGh6xN6XeREeIgyYB2aeHUpdQ5hFS5MivcTeY29E=";

  postInstall = ''
    install -Dm444 \
      rules.d/20-asd-backlight.rules \
      $out/lib/udev/rules.d/20-asd-backlight.rules
  '';

  doInstallCheck = true;

  meta = {
    description = "Apple Studio Display brightness controll";
    homepage = "https://github.com/juliuszint/asdbctl";
    changelog = "https://github.com/juliuszint/asdbctl/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = [
      lib.maintainers.danieldk
    ];

    mainProgram = "asdbctl";
  };
})
