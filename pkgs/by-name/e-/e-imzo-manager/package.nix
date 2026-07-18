{
  lib,
  stdenv,
  adwaita-icon-theme,
  cargo,
  desktop-file-utils,
  fetchFromForgejo,
  gdk-pixbuf,
  glib,
  gnome-desktop,
  gtk4,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  openssl,
  pkg-config,
  polkit,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "e-imzo-manager";
  version = "1.3.0";

  src = fetchFromForgejo {
    owner = "xinux";
    repo = "e-imzo-manager";
    tag = finalAttrs.version;
    hash = "sha256-QXAfrNPaq76HALhUlMdSygbfA5wJI4rGHDpnwPI/74w";
    domain = "git.oss.uzinfocom.uz";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    cargo
    rustPlatform.cargoSetupHook
    rustc
    desktop-file-utils
    wrapGAppsHook4
  ];

  buildInputs = [
    gdk-pixbuf
    glib
    gnome-desktop
    adwaita-icon-theme
    gtk4
    libadwaita
    openssl
    rustPlatform.bindgenHook
    polkit
  ];

  postInstall = ''
    gappsWrapperArgs+=(
      --suffix PATH : ${lib.makeBinPath finalAttrs.propagatedUserEnvPkgs}
    )
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-9yyTtMf1oCJWfFxWsaYWGT2/iTqU+3Ls0LIdHrNGZJI=";
  };

  propagatedUserEnvPkgs = [ polkit ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "GTK application for managing E-IMZO keys";
    homepage = "https://git.oss.uzinfocom.uz/xinux/e-imzo-manager";
    license = with lib.licenses; [ agpl3Plus ];

    maintainers = with lib.maintainers; [
      orzklv
      shakhzodkudratov
      bahrom04
      bemeritus
    ];

    platforms = lib.platforms.linux;
    mainProgram = "E-IMZO-Manager";
  };
})
