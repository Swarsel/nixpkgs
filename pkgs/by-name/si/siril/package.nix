{
  lib,
  stdenv,
  fetchFromGitLab,
  cfitsio,
  cmake,
  criterion,
  curl,
  exiv2,
  ffmpeg,
  ffms,
  fftwFloat,
  git,
  gnuplot,
  gsl,
  gtk3,
  gtksourceview4,
  json-glib,
  libconfig,
  libgit2,
  libheif,
  libjpeg,
  libjxl,
  libpng,
  libraw,
  librtprocess,
  libtiff,
  libxisf,
  meson,
  ninja,
  nix-update-script,
  opencv,
  pkg-config,
  python3,
  versionCheckHook,
  wcslib,
  wrapGAppsHook3,
  yyjson,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "siril";
  version = "1.4.4";

  src = fetchFromGitLab {
    owner = "free-astro";
    repo = "siril";
    tag = finalAttrs.version;
    hash = "sha256-UgG/efOMVeQJ1r219YOPkgkPqEdaXJquqXyWZW0oWgI=";
  };

  nativeBuildInputs = [
    meson
    ninja
    cmake
    pkg-config
    git
    criterion
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    cfitsio
    gsl
    exiv2
    gnuplot
    gtksourceview4
    opencv
    fftwFloat
    librtprocess
    wcslib
    libconfig
    libraw
    libtiff
    libpng
    libgit2
    libjpeg
    libjxl
    libheif
    libxisf
    ffms
    ffmpeg
    json-glib
    curl
    yyjson
  ];

  propagatedBuildInputs = [ python3 ];
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  # Necessary because project uses default build dir for flatpaks/snaps
  mesonBuildDir = "nixbld";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Astrophotographic image processing tool";
    homepage = "https://www.siril.org/";
    changelog = "https://gitlab.com/free-astro/siril/-/blob/HEAD/ChangeLog";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      returntoreality
    ];

    platforms = lib.platforms.linux;
    mainProgram = "siril";
  };
})
