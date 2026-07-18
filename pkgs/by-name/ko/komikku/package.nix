{
  lib,
  blueprint-compiler,
  desktop-file-utils,
  fetchFromCodeberg,
  gettext,
  glib,
  glib-networking,
  gnome,
  gobject-introspection,
  gtk4,
  libadwaita,
  libglycin,
  librsvg,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3,
  webkitgtk_6_0,
  webp-pixbuf-loader,
  wrapGAppsHook4,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "komikku";
  version = "50.9.0";

  src = fetchFromCodeberg {
    owner = "valos";
    repo = "Komikku";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fjAls3/ikNrQ1AgwUe9hFoQ48zv7UbGCUNB4dlmYM28=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    gettext
    glib # for glib-compile-resources
    desktop-file-utils
    gobject-introspection
    blueprint-compiler
  ];

  buildInputs = [
    glib
    glib-networking
    gtk4
    libadwaita
    libglycin
    webkitgtk_6_0
  ];

  # Tests require network
  doCheck = false;

  # Pull in WebP support for manga pics of some servers.
  # In postInstall to run before gappsWrapperArgsHook.
  postInstall = ''
    export GDK_PIXBUF_MODULE_FILE="${
      gnome._gdkPixbufCacheBuilder_DO_NOT_USE {
        extraLoaders = [
          librsvg
          webp-pixbuf-loader
        ];
      }
    }"
  '';

  dependencies = with python3.pkgs; [
    beautifulsoup4
    brotli
    colorthief
    dateparser
    ebooklib
    emoji
    jxlpy
    keyring
    lxml
    natsort
    piexif
    pillow
    curl-cffi
    pygobject3
    pyjwt
    pypdf
    python-magic
    rarfile
    requests
    unidecode
  ];

  # Prevent double wrapping.
  dontWrapGApps = true;
  makeWrapperArgs = [ "\${gappsWrapperArgs[@]}" ];
  pyproject = false;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Manga reader for GNOME";
    homepage = "https://apps.gnome.org/Komikku/";
    changelog = "https://codeberg.org/valos/Komikku/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      chuangzhu
      Gliczy
    ];

    mainProgram = "komikku";
    teams = [ lib.teams.gnome-circle ];
  };
})
