{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  nix-update-script,
  pkg-config,
  rustPlatform,
  udevCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "speakersafetyd";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "AsahiLinux";
    repo = "speakersafetyd";
    tag = finalAttrs.version;
    hash = "sha256-duIPpTzZqVSZLxF/CYlxa1PPtnzeABTCYfZZ7lomkls=";
  };

  postPatch = ''
    substituteInPlace speakersafetyd.service \
      --replace-fail "/usr" \
                     "$out"

    substituteInPlace Makefile \
      --replace-fail "target/release" \
                     "target/${stdenv.hostPlatform.rust.cargoShortTarget}/$cargoBuildType"
  '';

  nativeBuildInputs = [
    pkg-config
    udevCheckHook
  ];

  buildInputs = [ alsa-lib ];
  cargoHash = "sha256-gg1VcCrXKk5QsNvU7wz039md0gpFom6SrLuW6tjNQog=";
  doInstallCheck = true;
  dontCargoInstall = true;

  installFlags = [
    "DESTDIR=$(out)"
    "BINDIR=bin"
    "UNITDIR=lib/systemd/system"
    "UDEVDIR=lib/udev/rules.d"
    "SHAREDIR=share"
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Userspace daemon that implements the Smart Amp protection model";
    homepage = "https://github.com/AsahiLinux/speakersafetyd";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      flokli
      yuka
    ];

    platforms = lib.platforms.linux;
    mainProgram = "speakersafetyd";
  };
})
