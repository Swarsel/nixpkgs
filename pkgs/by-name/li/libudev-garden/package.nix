{
  lib,
  stdenv,
  fetchFromCodeberg,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libudev-garden";
  version = "0.2.1";

  src = fetchFromCodeberg {
    owner = "Gardenhouse";
    repo = "libudev-garden";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+95+3Hb6lkIhpNZF0pQdM9y5GxZCplp/o2nemZJb5Wc=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Daemonless replacement for libudev for use with gardendevd";
    homepage = "https://codeberg.org/Gardenhouse/libudev-garden";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      aanderse
      choco98
    ];

    platforms = lib.platforms.linux;
    pkgConfigModules = [ "libudev" ];
  };
})
