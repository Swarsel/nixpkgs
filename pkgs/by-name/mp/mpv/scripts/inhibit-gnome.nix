{
  lib,
  stdenv,
  fetchFromGitHub,
  dbus,
  gitUpdater,
  mpv-unwrapped,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mpv-inhibit-gnome";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "Guldoman";
    repo = "mpv_inhibit_gnome";
    rev = "v${finalAttrs.version}";
    hash = "sha256-LSGg5gAQE2JpepBqhz6D6d3NlqYaU4bjvYf1F+oLphQ=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    dbus
    mpv-unwrapped
  ];

  installPhase = ''
    install -D ./lib/mpv_inhibit_gnome.so $out/share/mpv/scripts/mpv_inhibit_gnome.so
  '';

  passthru.scriptName = "mpv_inhibit_gnome.so";
  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "This mpv plugin prevents screen blanking in GNOME";
    homepage = "https://github.com/Guldoman/mpv_inhibit_gnome";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ myaats ];
    platforms = lib.platforms.linux;
  };
})
