{
  lib,
  fetchFromCodeberg,
  gobject-introspection,
  libayatana-appindicator,
  libnotify,
  meson,
  ninja,
  pkg-config,
  procps,
  python3Packages,
  scdoc,
  wrapGAppsHook3,
  xautolock,
  xfconf,
  xscreensaver,
  xset,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "caffeine-ng";
  version = "4.3.2";

  src = fetchFromCodeberg {
    owner = "WhyNotHugo";
    repo = "caffeine-ng";
    rev = "v${finalAttrs.version}";
    hash = "sha256-eJ/0lzE5X1WFhgTAgI/SOmtxPbK7ppTk90RWobPZk2o=";
  };

  patches = [
    ./fix-build.patch
  ];

  postPatch = ''
    echo "${finalAttrs.version}" > version
  '';

  nativeBuildInputs = [
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    libayatana-appindicator
    libnotify
  ];

  postInstall = ''
    glib-compile-schemas $out/share/glib-2.0/schemas
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${
        lib.makeBinPath [
          procps
          xautolock
          xscreensaver
          xfconf
          xset
        ]
      }
    )
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dontWrapGApps = true;
  pyproject = false;

  pythonPath = with python3Packages; [
    click
    dbus-python
    ewmh
    pulsectl
    pygobject3
    scdoc
    setproctitle
  ];

  meta = {
    description = "Status bar application to temporarily inhibit screensaver and sleep mode";
    homepage = "https://codeberg.org/WhyNotHugo/caffeine-ng";
    changelog = "https://codeberg.org/WhyNotHugo/caffeine-ng/src/tag/v${finalAttrs.version}/CHANGELOG.rst";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ marzipankaiser ];
    platforms = lib.platforms.linux;
    mainProgram = "caffeine";
  };
})
