{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  libpulseaudio,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "camilladsp";
  version = "4.1.3";

  src = fetchFromGitHub {
    owner = "HEnquist";
    repo = "camilladsp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/OnD607xSPXM4AjVOZjaZQJpo7Q847Z8mq6elHmEwAU=";
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libpulseaudio
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ alsa-lib ];

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { extraArgs = [ "--generate-lockfile" ]; };

  meta = {
    description = "Flexible cross-platform IIR and FIR engine for crossovers, room correction etc";
    homepage = "https://github.com/HEnquist/camilladsp";
    changelog = "https://github.com/HEnquist/camilladsp/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      paepcke
      stepbrobd
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "camilladsp";
  };
})
