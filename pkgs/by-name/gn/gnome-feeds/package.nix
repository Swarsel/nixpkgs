{
  lib,
  fetchFromGitLab,
  appstream,
  blueprint-compiler,
  fetchpatch,
  glib-networking,
  gobject-introspection,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  python3,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "gnome-feeds";
  version = "2.2.0";

  src = fetchFromGitLab {
    owner = "World";
    repo = "gfeeds";
    rev = finalAttrs.version;
    hash = "sha256-XKwRFjz4ocH01mj8KshLGmGxbm/uvDiyYRf65KL0UFw=";
    domain = "gitlab.gnome.org";
  };

  patches = [
    # both patches needed to built with newer blueprint-compiler
    (fetchpatch {
      hash = "sha256-exkq9KykB60/X8u3+T1/sShrhGP8BvNkaBWPzm2mchc=";
      name = "fix-for-blueprint-0.8.patch";
      url = "https://gitlab.gnome.org/World/gfeeds/-/commit/cfe860f44f685be302e2ad9f30b55bab08e078ce.patch";
    })
    (fetchpatch {
      hash = "sha256-M6QLRTj+CItk3XPDeexf3/+B1YHJoHsTjwdE6iw1xjM=";
      name = "upgrade-blueprint-0.8-syntax.patch";
      url = "https://gitlab.gnome.org/World/gfeeds/-/commit/d099fda0c62e338080061683a154f711cc487b30.patch";
    })
  ];

  nativeBuildInputs = [
    appstream
    gobject-introspection
    meson
    ninja
    pkg-config
    blueprint-compiler
    wrapGAppsHook4
  ];

  buildInputs = [
    glib-networking
    libadwaita
    webkitgtk_6_0
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dependencies = with python3.pkgs; [
    beautifulsoup4
    humanize
    python-dateutil
    syndication-domination
    python-magic
    pillow
    pygments
    pygobject3
    readability-lxml
    pytz
    requests
  ];

  dontWrapGApps = true;
  pyproject = false;

  meta = {
    description = "RSS/Atom feed reader for GNOME";
    homepage = "https://gitlab.gnome.org/World/gfeeds";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      aleksana
    ];

    platforms = lib.platforms.linux;
    mainProgram = "gfeeds";
  };
})
