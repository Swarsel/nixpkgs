{
  lib,
  fetchFromGitHub,
  fetchFromGitLab,
  desktop-file-utils,
  gobject-introspection,
  gtksourceview5,
  libadwaita,
  libspelling,
  mathjax,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python312Packages,
  shared-mime-info,
  texliveMedium,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:

let
  version = "3.4";

  src = fetchFromGitLab {
    owner = "World";
    repo = "apostrophe";
    tag = "v${version}";
    hash = "sha256-Sj5Y4QPMYavdXbU+iVv76qOFNhgBjAeX9+/TvQHZzeI=";
    domain = "gitlab.gnome.org";
  };

  reveal-js = fetchFromGitHub {
    hash = "sha256-L6KVBw20K67lHT07Ws+ZC2DwdURahqyuyjAaK0kTgN0=";
    owner = "hakimel";
    repo = "reveal.js";
    # keep in sync with upstream shipped version
    # in build-aux/flatpak/org.gnome.gitlab.somas.Apostrophe.json
    tag = "5.1.0";
  };
in

# Requires telnetlib, and possibly others
# Try to remove in subsequent updates
python312Packages.buildPythonApplication {
  inherit version src;
  pname = "apostrophe";

  postPatch = ''
    substituteInPlace build-aux/meson_post_install.py \
      --replace-fail 'gtk-update-icon-cache' 'gtk4-update-icon-cache'

    patchShebangs --build build-aux/meson_post_install.py
  ''
  # Use mathjax from nixpkgs to avoid loading from CDN
  + ''
    substituteInPlace apostrophe/preview_converter.py \
      --replace-fail "--mathjax" "--mathjax=file://${mathjax}/lib/node_modules/mathjax/tex-chtml-full.js"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    desktop-file-utils
    gobject-introspection
  ];

  buildInputs = [
    libadwaita
    gtksourceview5
    libspelling
    webkitgtk_6_0
  ];

  # Should be done in postInstall, but meson checks this eagerly before build
  preConfigure = ''
    install -d $out/share/apostrophe/libs
    cp -r ${reveal-js} $out/share/apostrophe/libs/reveal.js
  '';

  preFixup = ''
    makeWrapperArgs+=(
      ''${gappsWrapperArgs[@]}
      --prefix PATH : "${texliveMedium}/bin"
      --prefix XDG_DATA_DIRS : "${shared-mime-info}/share"
    )
  '';

  dependencies = with python312Packages; [
    pygobject3
    pypandoc
    chardet
    levenshtein
    regex
  ];

  dontWrapGApps = true;
  pyproject = false;

  passthru = {
    inherit reveal-js;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Distraction free Markdown editor for GNU/Linux";
    homepage = "https://gitlab.gnome.org/World/apostrophe";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      sternenseemann
    ];

    platforms = lib.platforms.linux;
    mainProgram = "apostrophe";
    teams = [ lib.teams.gnome-circle ];
  };
}
