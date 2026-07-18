{
  lib,
  fetchFromGitHub,
  gobject-introspection,
  keybinder3,
  meson,
  ninja,
  pkg-config,
  python3Packages,
  wl-clipboard,
  wrapGAppsHook3,
  xdotool,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "emote";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "tom-james-watson";
    repo = "Emote";
    rev = "v${finalAttrs.version}";
    hash = "sha256-c5EY1Cc3oD8EG1oTChbl10jJlNeAETQbAFGoA9Lw5PY=";
  };

  postPatch = ''
    substituteInPlace emote/picker.py \
      --replace-fail 'os.environ.get("SNAP_VERSION", "dev build")' "'$version'"
    substituteInPlace emote/config.py \
      --replace-fail 'is_flatpak = os.environ.get("FLATPAK") is not None' 'is_flatpak = False' \
      --replace-fail 'os.environ.get("SNAP")' "'$out/share/emote'"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    # used by gobject-introspection's setup-hook and only detected at runtime
    keybinder3
  ];

  postInstall = ''
    rm $out/share/emote/emote/{emote.in,meson.build}
    rm $out/share/emote/static/{meson.build,com.tomjwatson.Emote.desktop,prepare-launch}
  '';

  preFixup = ''
    makeWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
      --prefix PATH : ${
        lib.makeBinPath [
          xdotool
          wl-clipboard
        ]
      }
    )
  '';

  dependencies = with python3Packages; [
    dbus-python.out # don't propagate dev output
    manimpango
    pygobject3.out # don't propagate dev output
    setproctitle
  ];

  dontWrapGApps = true;
  pyproject = false; # Built with meson

  meta = {
    description = "Modern emoji picker for Linux";
    homepage = "https://github.com/tom-james-watson/emote";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      emilytrau
      SuperSandro2000
      aleksana
    ];

    platforms = lib.platforms.linux;
    mainProgram = "emote";
  };
})
