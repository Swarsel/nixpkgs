{
  lib,
  stdenv,
  fetchFromGitHub,
  brightnessctl,
  cargo,
  coreutils,
  dbus,
  gtk4-layer-shell,
  libevdev,
  libinput,
  libpulseaudio,
  meson,
  ninja,
  pkg-config,
  rustPlatform,
  rustc,
  sassc,
  udev,
  udevCheckHook,
  wrapGAppsHook4,
}:
stdenv.mkDerivation rec {
  pname = "swayosd";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "ErikReider";
    repo = "SwayOSD";
    rev = "v${version}";
    hash = "sha256-NX2+QKQ7iSOkPls+nWMbwkrlK5TTMu8kGajSqJ0oGWI=";
  };

  patches = [
    ./swayosd_systemd_paths.patch
  ];

  postPatch = ''
    substituteInPlace data/udev/99-swayosd.rules \
      --replace /bin/chgrp ${coreutils}/bin/chgrp \
      --replace /bin/chmod ${coreutils}/bin/chmod
  '';

  nativeBuildInputs = [
    wrapGAppsHook4
    pkg-config
    meson
    rustc
    cargo
    ninja
    rustPlatform.cargoSetupHook
    udevCheckHook
  ];

  buildInputs = [
    gtk4-layer-shell
    libevdev
    libinput
    libpulseaudio
    dbus
    udev
    sassc
  ];

  doInstallCheck = true;

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ brightnessctl ]}
    )
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-BctsgIuzVCt2dJlu/rNVheWZu0TGyw4hzsotUZlKmMw=";
  };

  meta = {
    description = "GTK based on screen display for keyboard shortcuts";
    homepage = "https://github.com/ErikReider/SwayOSD";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      aleksana
      barab-i
      sergioribera
    ];

    platforms = lib.platforms.linux;
  };
}
