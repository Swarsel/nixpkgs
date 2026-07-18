{
  lib,
  stdenv,
  fetchFromGitHub,
  gdk-pixbuf,
  gitUpdater,
  gtk-engine-murrine,
  librsvg,
  meson,
  ninja,
  pkg-config,
  sassc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "greybird";
  version = "3.23.4";

  src = fetchFromGitHub {
    owner = "shimmerproject";
    repo = "greybird";
    rev = "v${finalAttrs.version}";
    hash = "sha256-De8y+LRQ26UKrUECLCcbCg7p9Z+aRssQ/7YzegAUPw4=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    sassc
  ];

  buildInputs = [
    gdk-pixbuf
    librsvg
  ];

  propagatedUserEnvPkgs = [
    gtk-engine-murrine
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Grey and blue theme from the Shimmer Project for GTK-based environments";
    homepage = "https://github.com/shimmerproject/Greybird";
    license = [ lib.licenses.gpl2Plus ]; # or alternatively: cc-by-nc-sa-30 or later
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.linux;
  };
})
