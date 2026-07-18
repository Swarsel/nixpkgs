{
  lib,
  stdenv,
  fetchurl,
  gitUpdater,
  libsndfile,
  lv2,
  meson,
  ninja,
  # test derivations
  pipewire,
  pkg-config,
  python3,
  serd,
  sord,
  sratom,
}:

stdenv.mkDerivation rec {
  pname = "lilv";
  version = "0.28.0";

  src = fetchurl {
    url = "https://download.drobilla.net/lilv-${version}.tar.xz";
    hash = "sha256-jctwrbXPByM1EVprCR9BE3EL3HOrqtqj+enB5VlXsUk=";
  };

  outputs = [
    "out"
    "dev"
    "man"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
  ];

  buildInputs = [
    libsndfile
    serd
    sord
    sratom
  ];

  propagatedBuildInputs = [ lv2 ];

  mesonFlags = [
    (lib.mesonOption "docs" "disabled")
    # Tests require building a shared library.
    (lib.mesonEnable "tests" (!stdenv.hostPlatform.isStatic))
  ]
  # Add nix and NixOS specific lv2 paths
  # The default values are from: https://github.com/lv2/lilv/blob/master/src/lilv_config.h
  ++ lib.optional stdenv.hostPlatform.isDarwin (
    lib.mesonOption "default_lv2_path" "~/.lv2:~/Library/Audio/Plug-Ins/LV2:"
    + "/usr/local/lib/lv2:/usr/lib/lv2:"
    + "/Library/Audio/Plug-Ins/LV2:"
    + "~/.nix-profile/lib/lv2"
  )
  ++ lib.optional stdenv.hostPlatform.isLinux (
    lib.mesonOption "default_lv2_path" "~/.lv2:/usr/local/lib/lv2:/usr/lib/lv2:"
    + "~/.nix-profile/lib/lv2:/run/current-system/sw/lib/lv2"
  );

  passthru = {
    tests = {
      inherit pipewire;
    };

    updateScript = gitUpdater {
      rev-prefix = "v";
      url = "https://gitlab.com/lv2/lilv.git";
    };
  };

  meta = {
    description = "C library to make the use of LV2 plugins";
    homepage = "http://drobilla.net/software/lilv";
    changelog = "https://gitlab.com/lv2/lilv/-/blob/v${version}/NEWS";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
