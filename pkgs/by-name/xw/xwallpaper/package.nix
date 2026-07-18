{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  installShellFiles,
  libjpeg,
  libpng,
  libseccomp,
  libxcb-image,
  libxcb-util,
  libxpm,
  pixman,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xwallpaper";
  version = "0.7.6";

  src = fetchFromGitHub {
    owner = "stoeckmann";
    repo = "xwallpaper";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-8VRQFH00yXplvhCqBuMGrwvOB7bJhfe50Ii6h8kvDMM=";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
    installShellFiles
  ];

  buildInputs = [
    pixman
    libxcb-image
    libxcb-util
    libseccomp
    libjpeg
    libpng
    libxpm
  ];

  postInstall = ''
    installShellCompletion --zsh _xwallpaper
  '';

  meta = {
    description = "Utility for setting wallpapers in X";
    homepage = "https://github.com/stoeckmann/xwallpaper";
    license = lib.licenses.isc;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "xwallpaper";
  };
})
