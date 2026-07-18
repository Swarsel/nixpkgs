{
  lib,
  fetchFromGitHub,
  glib,
  gtk3,
  libpulseaudio,
  pango,
  pkg-config,
  rustPlatform,
  wrapGAppsHook3,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "myxer";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "Aurailus";
    repo = "myxer";
    rev = finalAttrs.version;
    hash = "sha256-c5SHjnhWLp0jMdmDlupMTA0hWphub5DFY1vOI6NW8E0=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    libpulseaudio
    glib
    pango
    gtk3
  ];

  cargoHash = "sha256-ETwbNxAxm3m73FSTSZPF1eoheZ2o9/3GrEIOTeh2XDk=";
  # Currently no tests are implemented, so we avoid building the package twice
  doCheck = false;

  postInstall = ''
    install -Dm644 Myxer.desktop $out/share/applications/Myxer.desktop
  '';

  meta = {
    description = "Modern Volume Mixer for PulseAudio";
    homepage = "https://github.com/Aurailus/Myxer";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      erin
      rster2002
    ];

    platforms = lib.platforms.linux;
    mainProgram = "myxer";
  };
})
