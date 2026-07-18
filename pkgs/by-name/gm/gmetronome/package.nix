{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  gtkmm3,
  libpulseaudio,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gmetronome";
  version = "0.4.2";

  src = fetchFromGitLab {
    owner = "dqpb";
    repo = "gmetronome";
    rev = finalAttrs.version;
    hash = "sha256-/UWOvVeZILDR29VjBK+mFJt1hzWcOljOr7J7+cMrKtM=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    gtkmm3
    libpulseaudio
  ];

  meta = {
    description = "Free software metronome and tempo measurement tool";
    homepage = "https://gitlab.gnome.org/dqpb/gmetronome";
    changelog = "https://gitlab.gnome.org/dqpb/gmetronome/-/blob/${finalAttrs.src.rev}/NEWS";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.unix;
    mainProgram = "gmetronome";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
