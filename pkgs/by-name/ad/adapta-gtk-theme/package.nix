{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gdk-pixbuf,
  glib,
  gnome-shell,
  gtk-engine-murrine,
  inkscape,
  librsvg,
  libxml2,
  parallel,
  pkg-config,
  sassc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "adapta-gtk-theme";
  version = "3.95.0.11";

  src = fetchFromGitHub {
    owner = "adapta-project";
    repo = "adapta-gtk-theme";
    tag = finalAttrs.version;
    sha256 = "19skrhp10xx07hbd0lr3d619vj2im35d8p9rmb4v4zacci804q04";
  };

  postPatch = "patchShebangs .";

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    parallel
    sassc
    inkscape
    libxml2
    glib.dev
    gnome-shell
  ];

  buildInputs = [
    gdk-pixbuf
    librsvg
  ];

  configureFlags = [
    "--disable-gtk_legacy"
    "--disable-gtk_next"
    "--disable-unity"
  ];

  preferLocalBuild = true;
  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  meta = {
    description = "Adaptive GTK theme based on Material Design Guidelines";
    homepage = "https://github.com/adapta-project/adapta-gtk-theme";

    license = with lib.licenses; [
      gpl2
      cc-by-sa-30
    ];

    maintainers = with lib.maintainers; [ romildo ];
    platforms = lib.platforms.linux;
  };
})
