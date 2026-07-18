{
  lib,
  stdenv,
  fetchFromGitLab,
  docutils,
  gupnp-av,
  gupnp-dlna,
  gupnp_1_6,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dleyna";
  version = "0.8.3";

  src = fetchFromGitLab {
    owner = "World";
    repo = "dLeyna";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ti4yF8sALpWyrdQTt/jVrMKQ4PLhakEi620fJNMxT0c=";
    domain = "gitlab.gnome.org";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    meson
    ninja
    docutils
    pkg-config
  ];

  buildInputs = [
    gupnp_1_6
    gupnp-dlna
    gupnp-av
    gupnp-dlna
  ];

  mesonFlags = [
    # Sphinx docs not installed, do not depend on sphinx
    "-Ddocs=false"
  ];

  meta = {
    description = "Library of utility functions that are used by the higher level dLeyna";
    homepage = "https://gitlab.gnome.org/World/dLeyna";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ jtojnar ];
    platforms = lib.platforms.unix;
  };
})
