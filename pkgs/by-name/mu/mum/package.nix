{
  lib,
  fetchFromGitHub,
  alsa-lib,
  cmake,
  gdk-pixbuf,
  glib,
  installShellFiles,
  libnotify,
  libopus,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  withNotifications ? true,
  withOgg ? true,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mum";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "mum-rs";
    repo = "mum";
    tag = "v${finalAttrs.version}";
    hash = "sha256-r2isuwXq79dOQQWB+CsofYCLQYu9VKm7kzoxw103YV4=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    alsa-lib
    gdk-pixbuf
    glib
    libopus
    openssl
  ]
  ++ lib.optional withNotifications libnotify;

  cargoHash = "sha256-ey3nT6vZ5YOZGk08HykK9RxI7li+Sz+sER3HioGSXP0=";

  postInstall = ''
    installManPage documentation/*.{1,5}
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  buildFeatures = lib.optional withNotifications "notifications" ++ lib.optional withOgg "ogg";
  buildNoDefaultFeatures = true;
  versionCheckProgram = "${placeholder "out"}/bin/mumctl";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Daemon/cli mumble client";
    homepage = "https://github.com/mum-rs/mum";
    changelog = "https://github.com/mum-rs/mum/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lykos153 ];
  };
})
