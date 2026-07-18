{
  lib,
  fetchFromGitLab,
  adwaita-icon-theme,
  docutils,
  farstream,
  gettext,
  glib-networking,
  gobject-introspection,
  gsound,
  gst-libav,
  gst-plugins-base,
  gst-plugins-good,
  gstreamer,
  gtk4,
  gtksourceview5,
  gupnp-igd,
  libadwaita,
  libappindicator-gtk3,
  libnice,
  libsecret,
  libspelling,
  # Native dependencies
  python3,
  wrapGAppsHook3,
  enableAppIndicator ? true,
  # Optional dependencies
  enableJingle ? true,
  enableRST ? true,
  enableSecrets ? true,
  enableSoundNotifications ? true,
  enableSpelling ? true,
  enableUPnP ? true,
  extraPythonPackages ? ps: [ ],
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "gajim";
  version = "2.4.7.1";

  src = fetchFromGitLab {
    owner = "gajim";
    repo = "gajim";
    tag = "${finalAttrs.version}+win";
    hash = "sha256-/X2Xp1ZnPLTZc1Hf4Kp6R/+mezU6qoUhaT9OskYlnOY=";
    domain = "dev.gajim.org";
  };

  # necessary for wrapGAppsHook3
  strictDeps = false;

  nativeBuildInputs = [
    gettext
    wrapGAppsHook3
    gobject-introspection
    libadwaita
  ];

  buildInputs = [
    gtk4
    adwaita-icon-theme
    gtksourceview5
    glib-networking
  ]
  ++ lib.optionals enableJingle [
    farstream
    gstreamer
    gst-plugins-base
    gst-libav
    gst-plugins-good
    libnice
  ]
  ++ lib.optional enableSecrets libsecret
  ++ lib.optional enableSpelling libspelling
  ++ lib.optional enableUPnP gupnp-igd
  ++ lib.optional enableAppIndicator libappindicator-gtk3
  ++ lib.optional enableSoundNotifications gsound;

  propagatedBuildInputs =
    with python3.pkgs;
    [
      nbxmpp
      dbus-python
      pillow
      css-parser
      precis-i18n
      keyring
      setuptools
      packaging
      gssapi
      omemo-dr
      qrcode
      sqlalchemy
      emoji
      httpx
      h2
      truststore
      pysequoia
    ]
    ++ httpx.optional-dependencies.socks
    ++ lib.optional enableRST docutils
    ++ extraPythonPackages python3.pkgs;

  preBuild = ''
    python make.py build --dist unix
  '';

  nativeCheckInputs = [
    python3.pkgs.pytestCheckHook
  ];

  postInstall = ''
    python make.py install --dist unix --prefix=$out
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dontWrapGApps = true;
  pyproject = true;

  meta = {
    description = "XMPP chat client";
    longDescription = "Gajim aims to be an easy to use and fully-featured XMPP client. Just chat with your friends or family, easily share pictures and thoughts or discuss the news with your groups.";
    homepage = "http://gajim.org/";
    changelog = "https://dev.gajim.org/gajim/gajim/-/blob/${finalAttrs.version}/ChangeLog";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      raskin
      hlad
      vbgl
      haansn08
    ];

    platforms = lib.platforms.linux;
    mainProgram = "gajim";
    donationPage = "https://liberapay.com/Gajim";
    downloadPage = "http://gajim.org/download/";
    identifiers.cpeParts = lib.meta.cpeFullVersionWithVendor "gajim" finalAttrs.version;
  };
})
