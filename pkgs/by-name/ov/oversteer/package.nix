{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream,
  appstream-glib,
  bash,
  desktop-file-utils,
  gettext,
  gobject-introspection,
  gtk3,
  linuxConsoleTools,
  meson,
  ninja,
  pkg-config,
  python3,
  python3Packages,
  udev,
  udevCheckHook,
  wrapGAppsHook3,
}:

let
  python = python3.withPackages (
    p: with p; [
      pygobject3
      pyudev
      pyxdg
      evdev
      matplotlib
      scipy
      gtk3
      pygobject3
    ]
  );

in
stdenv.mkDerivation (finalAttrs: {
  pname = "oversteer";
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "berarma";
    repo = "oversteer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-X58U7lFH53nCaXnE7uXgV7aea6qntNfH5TIt68xSefY=";
  };

  patches = [ ];

  nativeBuildInputs = [
    pkg-config
    gettext
    python
    wrapGAppsHook3
    gobject-introspection
    meson
    udev
    udevCheckHook
    ninja
    appstream
    appstream-glib
    desktop-file-utils
  ];

  buildInputs = [
    bash
    gtk3
  ];

  propagatedBuildInputs = [
    python
    gtk3
    python3Packages.pygobject3
  ];

  mesonFlags = [
    "--prefix"
    (placeholder "out")
    "-Dudev_rules_dir=${placeholder "out"}/lib/udev/rules.d/"
  ];

  postInstall = ''
    substituteInPlace $out/lib/udev/rules.d/* \
      --replace-fail /bin/sh ${bash}/bin/sh
    substituteInPlace $out/lib/udev/rules.d/99-fanatec-wheel-perms.rules \
      --replace-fail /usr/bin/evdev-joystick ${linuxConsoleTools}/bin/evdev-joystick
  '';

  doInstallCheck = true;

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}"
    )
  '';

  dontUseCmakeConfigure = true;

  meta = {
    description = "Steering Wheel Manager for Linux";
    homepage = "https://github.com/berarma/oversteer";
    changelog = "https://github.com/berarma/oversteer/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.srounce ];
    platforms = lib.platforms.unix;
    mainProgram = "oversteer";
  };
})
