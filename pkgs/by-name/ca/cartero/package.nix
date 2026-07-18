{
  lib,
  stdenv,
  fetchFromGitHub,
  blueprint-compiler,
  cargo,
  desktop-file-utils,
  glib,
  gtk4,
  gtksourceview5,
  hicolor-icon-theme,
  libadwaita,
  libxml2,
  meson,
  ninja,
  openssl,
  pango,
  pkg-config,
  python313,
  rustPlatform,
  rustc,
  shared-mime-info,
  wrapGAppsHook4,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "cartero";
  version = "26.0";

  src = fetchFromGitHub {
    owner = "danirod";
    repo = "cartero";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EBQqJuIcgpLtRu5DcAaWnCiFyiuuG+DCkdAWsoWwn3E=";
  };

  postPatch = ''
    patchShebangs --build build-aux/gen-version.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    cargo
    rustc
    blueprint-compiler
    wrapGAppsHook4
    desktop-file-utils
    libxml2
    python313
    gtk4
    shared-mime-info
    glib
    hicolor-icon-theme
  ];

  buildInputs = [
    libadwaita
    gtksourceview5
    openssl
    pango
    libadwaita
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-Te6foGMcy8q0u6wn/D4RkhoOEjke5HTv3xxaS2EbiIE=";
  };

  meta = {
    description = "Make HTTP requests and test APIs";

    longDescription = ''
      Cartero is a graphical HTTP client that can be used
      as a developer tool to test web APIs and perform all
      kind of HTTP requests to web servers. It is compatible
      with any REST, SOAP or XML-RPC API and it supports
      multiple request methods as well as attaching body
      payloads to compatible requests.
    '';

    homepage = "https://cartero.danirod.es";
    changelog = "https://github.com/danirod/cartero/releases";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      aleksana
      amerino
      _0xErwin1
    ];

    platforms = lib.platforms.linux;
    mainProgram = "cartero";
  };
})
