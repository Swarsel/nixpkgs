{
  lib,
  stdenv,
  fetchFromSourcehut,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  wayland,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libscfg";
  version = "0.1.1";

  src = fetchFromSourcehut {
    owner = "~emersion";
    repo = "libscfg";
    rev = "v${finalAttrs.version}";
    hash = "sha256-aTcvs7QuDOx17U/yP37LhvIGxmm2WR/6qFYRtfjRN6w=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [ wayland ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple configuration file format";
    homepage = "https://sr.ht/~emersion/libscfg";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ michaeladler ];
    platforms = lib.platforms.linux;
  };
})
