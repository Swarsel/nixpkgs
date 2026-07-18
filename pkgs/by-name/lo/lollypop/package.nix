{
  lib,
  fetchFromGitLab,
  appstream-glib,
  desktop-file-utils,
  gdk-pixbuf,
  glib,
  glib-networking,
  gobject-introspection,
  gst_all_1,
  gtk3,
  kid3,
  libhandy,
  libsecret,
  libsoup_3,
  meson,
  ninja,
  nix-update-script,
  pango,
  pkg-config,
  python3,
  totem-pl-parser,
  wrapGAppsHook3,
  kid3Support ? true,
  lastFMSupport ? true,
  youtubeSupport ? true,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "lollypop";
  version = "1.4.40";

  src = fetchFromGitLab {
    owner = "World";
    repo = "lollypop";
    rev = finalAttrs.version;
    hash = "sha256-hdReviNgcigXuNqJns6aPW+kixlpmRXtqrLlm/LGHBo=";
    fetchSubmodules = true;
    domain = "gitlab.gnome.org";
  };

  postPatch = ''
    chmod +x meson_post_install.py
    patchShebangs meson_post_install.py
  '';

  strictDeps = false;

  nativeBuildInputs = [
    appstream-glib
    desktop-file-utils
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs =
    (with gst_all_1; [
      gst-libav
      gst-plugins-bad
      gst-plugins-base
      gst-plugins-good
      gst-plugins-ugly
      gstreamer

    ])
    ++ [
      gdk-pixbuf
      glib
      glib-networking
      gtk3
      libhandy
      libsoup_3
      pango
      totem-pl-parser
    ]
    ++ lib.optional lastFMSupport libsecret;

  propagatedBuildInputs =
    (with python3.pkgs; [
      beautifulsoup4
      pillow
      pycairo
      pygobject3
    ])
    ++ lib.optional lastFMSupport python3.pkgs.pylast
    ++ lib.optional youtubeSupport python3.pkgs.yt-dlp
    ++ lib.optional kid3Support kid3;

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postFixup = ''
    wrapPythonProgramsIn $out/libexec "$out $propagatedBuildInputs"
  '';

  # Produce only one wrapper using wrap-python passing
  # gappsWrapperArgs to wrap-python additional wrapper
  # argument
  dontWrapGApps = true;
  pyproject = false;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Modern music player for GNOME";
    homepage = "https://gitlab.gnome.org/World/lollypop";
    changelog = "https://gitlab.gnome.org/World/lollypop/tags/${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ lovesegfault ];
    platforms = lib.platforms.linux;
    mainProgram = "lollypop";
  };
})
