{
  lib,
  fetchFromGitHub,
  atk,
  brightnessctl, # brightnessctl
  gdk-pixbuf,
  gobject-introspection,
  gtk-layer-shell,
  # Extra packages called by various internal nwg-panel modules
  hyprland, # hyprctl
  libdbusmenu-gtk3, # tray
  nwg-menu, # nwg-menu
  pamixer, # pamixer
  pango,
  playerctl,
  pulseaudio, # pactl
  python3Packages,
  sway, # swaylock, swaymsg
  systemd, # systemctl
  wlr-randr, # wlr-randr
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "nwg-panel";
  version = "0.10.15";

  src = fetchFromGitHub {
    owner = "nwg-piotr";
    repo = "nwg-panel";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zRoOsVnwn2DQctB9ZP0pAAnf9Ragd2RZGHZGN1KnMsQ=";
  };

  # Because of wrapGAppsHook3
  strictDeps = false;

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    atk
    gdk-pixbuf
    gtk-layer-shell
    pango
    playerctl
  ];

  propagatedBuildInputs =
    (with python3Packages; [
      i3ipc
      netifaces
      psutil
      pybluez
      pygobject3
      requests
      dasbus
      setuptools
    ])
    # Run-time GTK dependency required by the Tray module
    ++ [ libdbusmenu-gtk3 ];

  # No tests
  doCheck = false;

  postInstall = ''
    install -D $src/nwg-panel-config.desktop nwg-processes.desktop -t $out/share/applications/
    install -D $src/nwg-shell.svg $src/nwg-panel.svg nwg-processes.svg -t $out/share/icons/hicolor/scalable/apps/
  '';

  preFixup = ''
    makeWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
      --prefix XDG_DATA_DIRS : "$out/share"
      --prefix PATH : "${
        lib.makeBinPath [
          brightnessctl
          hyprland
          nwg-menu
          pamixer
          pulseaudio
          sway
          systemd
          wlr-randr
        ]
      }"
    )
  '';

  dontWrapGApps = true;
  format = "setuptools";

  meta = {
    description = "GTK3-based panel for Sway window manager";
    homepage = "https://github.com/nwg-piotr/nwg-panel";
    changelog = "https://github.com/nwg-piotr/nwg-panel/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ludovicopiero ];
    platforms = lib.platforms.linux;
    mainProgram = "nwg-panel";
  };
})
