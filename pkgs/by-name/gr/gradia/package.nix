{
  lib,
  fetchFromGitHub,
  appstream,
  bash,
  blueprint-compiler,
  desktop-file-utils,
  glib-networking,
  gnome,
  gobject-introspection,
  gtksourceview5,
  libadwaita,
  libportal-gtk4,
  librsvg,
  libsoup_3,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3Packages,
  tesseract,
  webp-pixbuf-loader,
  wrapGAppsHook4,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "gradia";
  version = "1.13.0";

  src = fetchFromGitHub {
    owner = "AlexanderVanhee";
    repo = "Gradia";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9gxxl59jceZZIja/fg7ygbhjcHUo4TEEnK/IzJLsRgM=";
  };

  postPatch = ''
    substituteInPlace meson.build \
      --replace "/app/bin/tesseract" "${lib.getExe tesseract}"
  '';

  nativeBuildInputs = [
    meson
    ninja
    appstream
    desktop-file-utils
    gobject-introspection
    wrapGAppsHook4
    blueprint-compiler
    pkg-config
  ];

  buildInputs = [
    gtksourceview5
    libadwaita
    libportal-gtk4
    libsoup_3
    bash
    glib-networking
    tesseract
  ];

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
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  __structuredAttrs = true;

  dependencies = with python3Packages; [
    pygobject3
    pillow
    pytesseract
  ];

  dontWrapGApps = true;
  pyproject = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Make your screenshots ready for the world";
    homepage = "https://github.com/AlexanderVanhee/Gradia";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      Cameo007
      quadradical
      claymorwan
    ];

    platforms = lib.platforms.linux;
    mainProgram = "gradia";
  };
})
