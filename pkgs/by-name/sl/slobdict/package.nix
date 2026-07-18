{
  lib,
  stdenv,
  fetchFromGitHub,
  blueprint-compiler,
  glib,
  gobject-introspection,
  gtk4,
  libadwaita,
  libzim,
  meson,
  ninja,
  pkg-config,
  python3Packages,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "slobdict";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "MuntashirAkon";
    repo = "SlobDict";
    tag = finalAttrs.version;
    hash = "sha256-4u0VqaPDpyflWkN119IOVqKxpsskou3ou1dqpuRSaHI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    blueprint-compiler
    glib
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    glib
    libadwaita
    libzim
    webkitgtk_6_0
  ];

  postBuild = ''
    glib-compile-schemas --strict ../gnome-extension/slobdict@muntashir.dev/schemas
  '';

  postInstall = ''
    chmod +x $out/bin/slobdict

    mkdir -p $out/share/gnome-shell/extensions/slobdict@muntashir.dev
    cp -r ../gnome-extension/slobdict@muntashir.dev/schemas $out/share/gnome-shell/extensions/slobdict@muntashir.dev
    cp ../gnome-extension/slobdict@muntashir.dev/{extension.js,metadata.json} $out/share/gnome-shell/extensions/slobdict@muntashir.dev
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dependencies = with python3Packages; [
    pygobject3
    pyglossary

    # Optional deps of pyglossary
    pyyaml
    beautifulsoup4
    biplist
    # colorize-pinyin not packaged
    html5lib
    marisa-trie
    mistune
    polib
    prompt-toolkit
    pymorphy3
    # python-romkan-ng not packaged
    xxhash

    # Deps for cli mode
    pygments
    rich
    premailer
    cssutils
    markdownify
  ];

  # Prevent double wrapping, let the Python wrapper use the args in preFixup.
  dontWrapGApps = true;
  pyproject = false; # built with meson

  passthru = {
    extensionPortalSlug = "slobdict";
    extensionUuid = "slobdict@muntashir.dev";
  };

  meta = {
    description = "Modern, lightweight GTK 4 dictionary app";
    homepage = "https://github.com/MuntashirAkon/SlobDict";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ linsui ];
    platforms = lib.platforms.linux;
    mainProgram = "slobdict";
  };
})
