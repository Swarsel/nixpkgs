{
  lib,
  stdenv,
  fetchFromGitHub,
  clapper-enhancers,
  clapper-unwrapped,
  desktop-file-utils,
  gexiv2,
  glib,
  glib-networking,
  gnome,
  gobject-introspection,
  gst_all_1,
  gtk4,
  gtksourceview5,
  icu,
  json-glib,
  libadwaita,
  libgee,
  librsvg,
  libsecret,
  libsoup_3,
  libspelling,
  libwebp,
  libxml2,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3,
  vala,
  webkitgtk_6_0,
  webp-pixbuf-loader,
  wrapGAppsHook4,
  clapperSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tuba";
  version = "0.10.3";

  src = fetchFromGitHub {
    owner = "GeopJr";
    repo = "Tuba";
    rev = "v${finalAttrs.version}";
    hash = "sha256-uMfxHQOjL1bnKAz0MUUEv2IR4aRiR4UhIM5aHPspJDU=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    python3
    wrapGAppsHook4
    desktop-file-utils
    gobject-introspection
  ];

  buildInputs = [
    gexiv2
    glib
    glib-networking
    gtksourceview5
    json-glib
    libxml2
    libgee
    libsoup_3
    gtk4
    libadwaita
    libsecret
    libwebp
    libspelling
    webkitgtk_6_0
    icu
  ]
  ++ (with gst_all_1; [
    gstreamer
    gst-libav
    gst-plugins-base
    (gst-plugins-good.override { gtkSupport = true; })
    gst-plugins-bad
  ])
  ++ lib.optionals clapperSupport [
    clapper-unwrapped
  ];

  mesonFlags = [
    (lib.mesonEnable "clapper" clapperSupport)
  ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-error=int-conversion";

  # Pull in WebP support for avatars from Misskey instances.
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

  preFixup = ''
    gappsWrapperArgs+=(
      --set-default CLAPPER_ENHANCERS_PATH "${clapper-enhancers}/${clapper-enhancers.passthru.pluginPath}"
    )
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Browse the Fediverse";
    homepage = "https://tuba.geopjr.dev/";
    changelog = "https://github.com/GeopJr/Tuba/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      chuangzhu
      donovanglover
    ];

    mainProgram = "dev.geopjr.Tuba";
    teams = [ lib.teams.gnome-circle ];
  };
})
