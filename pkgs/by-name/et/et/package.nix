{
  lib,
  stdenv,
  fetchFromGitHub,
  gdk-pixbuf,
  libnotify,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "et";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "oxzi";
    repo = "et";
    rev = finalAttrs.version;
    sha256 = "0i0lgmnly8n7y4y6pb10pxgxyz8s5zk26k8z1g1578v1wan01lnq";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libnotify
    gdk-pixbuf
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp et $out/bin
    cp et-status.sh $out/bin/et-status
  '';

  meta = {
    description = "Minimal libnotify-based (egg) timer";
    homepage = "https://github.com/oxzi/et";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
