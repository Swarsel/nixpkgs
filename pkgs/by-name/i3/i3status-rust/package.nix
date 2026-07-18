{
  lib,
  fetchFromGitHub,
  dbus,
  ethtool,
  installShellFiles,
  iproute2,
  iw,
  libpulseaudio,
  lm_sensors,
  makeWrapper,
  notmuch,
  openssl,
  pandoc,
  pipewire,
  pkg-config,
  rustPlatform,
  withICUCalendar ? false,
  withNotmuch ? false,
  withPipewire ? true,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "i3status-rust";
  version = "0.36.1";

  src = fetchFromGitHub {
    owner = "greshake";
    repo = "i3status-rust";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tCMoYbsiVBX7GZZVhzAKuMFS1L7DITQZSUfQ6iQMofg=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    installShellFiles
    pandoc
  ]
  ++ (lib.optionals withPipewire [ rustPlatform.bindgenHook ]);

  buildInputs = [
    dbus
    libpulseaudio
    openssl
    lm_sensors
  ]
  ++ (lib.optionals withPipewire [ pipewire ])
  ++ (lib.optionals withNotmuch [ notmuch ]);

  cargoHash = "sha256-mnLl+JegA96z95VQqZ5d8bGYCf1PG/ip2LVyPm4HjVI=";

  postBuild = ''
    cargo xtask generate-manpage
  '';

  # Currently no tests are implemented, so we avoid building the package twice
  doCheck = false;

  postInstall = ''
    mkdir -p $out/share
    cp -R examples files/* $out/share
    installManPage man/*
  '';

  postFixup = ''
    wrapProgram $out/bin/i3status-rs --prefix PATH : ${
      lib.makeBinPath [
        iproute2
        ethtool
        iw
      ]
    }
  '';

  buildFeatures = [
    "maildir"
    "pulseaudio"
  ]
  ++ (lib.optionals withICUCalendar [ "icu_calendar" ])
  ++ (lib.optionals withPipewire [ "pipewire" ])
  ++ (lib.optionals withNotmuch [ "notmuch" ]);

  prePatch = ''
    substituteInPlace src/util.rs \
      --replace "/usr/share/i3status-rust" "$out/share"
  '';

  meta = {
    description = "Very resource-friendly and feature-rich replacement for i3status";
    homepage = "https://github.com/greshake/i3status-rust";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      backuitist
    ];

    platforms = lib.platforms.linux;
    mainProgram = "i3status-rs";
  };
})
