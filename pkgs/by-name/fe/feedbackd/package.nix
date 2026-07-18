{
  lib,
  stdenv,
  fetchFromGitLab,
  dbus,
  docbook-xsl-nons,
  docutils,
  feedbackd-device-themes,
  gi-docgen,
  glib,
  gmobile,
  gobject-introspection,
  gsound,
  gtk-doc,
  json-glib,
  libgudev,
  libxslt,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  testers,
  udevCheckHook,
  umockdev,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "feedbackd";
  version = "0.8.9";

  src = fetchFromGitLab {
    owner = "feedbackd";
    repo = "feedbackd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4cbH5jzbLROs/FtbiktlyZPGPYiIo3wgqgOCzyzNzzs=";
    domain = "gitlab.freedesktop.org";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  postPatch = ''
    patchShebangs run.in

    substituteInPlace data/72-feedbackd.rules \
      --replace-fail '/usr/libexec/' "$out/libexec/"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    docbook-xsl-nons
    docutils # for rst2man
    gi-docgen
    gobject-introspection
    gtk-doc
    libxslt
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook3
    udevCheckHook
  ];

  buildInputs = [
    glib
    gsound
    json-glib
    libgudev
    gmobile
  ];

  mesonFlags = [
    "-Dgtk_doc=true"
    "-Dman=true"
    "-Dmedia-roles=true"
    # Make compiling work when doCheck = false
    "-Dtests=${lib.boolToString finalAttrs.finalPackage.doCheck}"
  ];

  doCheck = true;

  nativeCheckInputs = [
    dbus
    umockdev
  ];

  doInstallCheck = true;

  postFixup = ''
    # Move developer documentation to devdoc output.
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    if [[ -d "$out/share/doc" ]]; then
        find -L "$out/share/doc" -type f -regex '.*\.devhelp2?' -print0 \
          | while IFS= read -r -d ''' file; do
            moveToOutput "$(dirname "''${file/"$out/"/}")" "$devdoc"
        done
    fi
  '';

  depsBuildBuild = [
    pkg-config
  ];

  passthru = {
    tests.pkg-config = testers.hasPkgConfigModules {
      package = finalAttrs.finalPackage;
      versionCheck = true;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Theme based Haptic, Visual and Audio Feedback";
    homepage = "https://gitlab.freedesktop.org/feedbackd/feedbackd/";

    license = with lib.licenses; [
      # feedbackd
      gpl3Plus

      # libfeedback library
      lgpl21Plus
    ];

    maintainers = with lib.maintainers; [
      pacman99
      Luflosi
    ];

    platforms = lib.platforms.linux;
    pkgConfigModules = [ "libfeedback-0.0" ];
  };
})
