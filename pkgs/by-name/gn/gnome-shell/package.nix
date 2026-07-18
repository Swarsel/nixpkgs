{
  lib,
  stdenv,
  fetchurl,
  accountsservice,
  adwaita-icon-theme,
  at-spi2-core,
  bash-completion,
  desktop-file-utils,
  docutils,
  evolution-data-server-gtk4,
  fetchpatch,
  gcr_4,
  gdk-pixbuf,
  gdm,
  geoclue2,
  gettext,
  gi-docgen,
  gjs,
  glib,
  glycin-loaders,
  gnome,
  gnome-autoar,
  gnome-bluetooth,
  gnome-clocks,
  gnome-desktop,
  gnome-keyring,
  gnome-settings-daemon,
  gobject-introspection,
  gsettings-desktop-schemas,
  gst_all_1,
  gtk4,
  ibus,
  json-glib,
  lcms2,
  libGL,
  libadwaita,
  libgbm,
  libgweather,
  libical,
  libjxl,
  libnma-gtk4,
  libpulseaudio,
  librsvg,
  libsecret,
  libsoup_3,
  libx11,
  libxi,
  libxkbcommon,
  libxml2,
  libxslt,
  meson,
  mutter,
  networkmanager,
  ninja,
  pipewire,
  pkg-config,
  polkit,
  python3,
  replaceVars,
  sassc,
  shared-mime-info,
  systemd,
  unzip,
  upower,
  webkitgtk_6_0,
  webp-pixbuf-loader,
  wrapGAppsHook4,
}:

let
  pythonEnv = python3.withPackages (ps: with ps; [ pygobject3 ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-shell";
  version = "50.2";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-shell/${lib.versions.major finalAttrs.version}/gnome-shell-${finalAttrs.version}.tar.xz";
    hash = "sha256-UyFUIOUO/dTQYRultZ4Qy0yJ+j9R4q3f2Vyt4GGgmik=";
  };

  outputs = [
    "out"
    "devdoc"
  ];

  patches = [
    # Hardcode paths to various dependencies so that they can be found at runtime.
    (replaceVars ./fix-paths.patch {
      glib_compile_schemas = "${glib.dev}/bin/glib-compile-schemas";
      gsettings = "${glib.bin}/bin/gsettings";
      unzip = "${lib.getBin unzip}/bin/unzip";
    })

    # Use absolute path for libshew installation to make our patched gobject-introspection
    # aware of the location to hardcode in the generated GIR file.
    ./shew-gir-path.patch

    # Make D-Bus services wrappable.
    ./wrap-services.patch

    # Fix greeter logo being too big.
    # https://gitlab.gnome.org/GNOME/gnome-shell/issues/2591
    # Reverts https://gitlab.gnome.org/GNOME/gnome-shell/-/merge_requests/1101
    ./greeter-logo-size.patch

    # Work around failing fingerprint auth
    (fetchpatch {
      hash = "sha256-mgXty5HhiwUO1UV3/eDgWtauQKM0cRFQ0U7uocST25s=";
      url = "https://src.fedoraproject.org/rpms/gnome-shell/raw/dcd112d9708954187e7490564c2229d82ba5326f/f/0001-gdm-Work-around-failing-fingerprint-auth.patch";
    })
  ];

  postPatch = ''
    patchShebangs \
      src/data-to-c.py \
      build-aux/generate-app-list.py

    # We can generate it ourselves.
    rm -f man/gnome-shell.1
    rm data/theme/gnome-shell-{light,dark}.css
  '';

  nativeBuildInputs = [
    docutils # for rst2man
    meson
    ninja
    pkg-config
    gettext
    gi-docgen
    wrapGAppsHook4
    sassc
    desktop-file-utils
    libxslt.bin
    gobject-introspection
  ];

  buildInputs = [
    systemd
    gsettings-desktop-schemas
    gnome-keyring
    glib
    gcr_4
    accountsservice
    libsecret
    polkit
    gdk-pixbuf
    librsvg
    networkmanager
    gjs
    mutter
    libpulseaudio
    evolution-data-server-gtk4
    libical
    gtk4
    libadwaita
    gdm
    geoclue2
    adwaita-icon-theme
    gnome-bluetooth
    gnome-clocks # schemas needed
    at-spi2-core
    upower
    ibus
    gnome-desktop
    gnome-settings-daemon
    lcms2 # required by mutter-clutter
    libgbm
    libGL # for egl, required by mutter-clutter
    libxi # required by libmutter
    libx11
    libxkbcommon
    libsoup_3
    libxml2

    # recording
    pipewire
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good

    # not declared at build time, but typelib is needed at runtime
    libgweather
    libnma-gtk4
    webkitgtk_6_0 # for gnome-shell-portal-helper

    # for gnome-extension tool
    bash-completion
    gnome-autoar
    json-glib

    # for tools
    pythonEnv
  ];

  mesonFlags = [
    "-Dgtk_doc=true"
    "-Dtests=false"
  ];

  preInstall = ''
    # gnome-shell contains GSettings schema overrides for Mutter.
    schemadir="$out/share/glib-2.0/schemas"
    mkdir -p "$schemadir"
    cp "${glib.getSchemaPath mutter}/org.gnome.mutter.gschema.xml" "$schemadir"
  '';

  postInstall = ''
    # Pull in WebP and JXL support for gnome-backgrounds.
    # In postInstall to run before gappsWrapperArgsHook.
    export GDK_PIXBUF_MODULE_FILE="${
      gnome._gdkPixbufCacheBuilder_DO_NOT_USE {
        extraLoaders = [
          libjxl
          librsvg
          webp-pixbuf-loader
        ];
      }
    }"
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix XDG_DATA_DIRS : ${
        lib.makeSearchPath "share" [
          # Until glib’s xdgmime is patched
          # Fixes “Failed to load resource:///org/gnome/shell/theme/noise-texture.png: Unrecognized image file format”
          shared-mime-info
          # For background images https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/4554
          glycin-loaders
        ]
      }
    )
  '';

  postFixup = ''
    # The services need typelibs.
    for svc in org.gnome.ScreenSaver org.gnome.Shell.Extensions org.gnome.Shell.Notifications org.gnome.Shell.Screencast; do
      wrapGApp $out/share/gnome-shell/$svc
    done

    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  separateDebugInfo = true;

  passthru = {
    mozillaPlugin = "/lib/mozilla/plugins";

    updateScript = gnome.updateScript {
      packageName = "gnome-shell";
    };
  };

  meta = {
    description = "Core user interface for the GNOME 3 desktop";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-shell";
    changelog = "https://gitlab.gnome.org/GNOME/gnome-shell/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.gnome ];
  };

})
