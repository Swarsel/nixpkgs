{
  lib,
  stdenv,
  fetchFromGitLab,
  fetchpatch,
  gitUpdater,
  inih,
  libdrm,
  libinput,
  libxkbcommon,
  meson,
  ninja,
  pkg-config,
  scdoc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "buffybox";
  version = "3.5.1";

  src = fetchFromGitLab {
    owner = "postmarketOS";
    repo = "buffybox";
    tag = finalAttrs.version;
    hash = "sha256-aOPfKqnUIkJozt+DwVJjbNQEcmpjCmUgJUjTx9LV23M=";
    fetchSubmodules = true; # to use its vendored lvgl
    domain = "gitlab.postmarketos.org";
  };

  patches = [
    /*
      There's a close to zero chance that anyone with a 32-bit machine will be using BuffyBox.
      In the case that it happens, I expect no complaints whatsoever.

      https://gitlab.postmarketos.org/postmarketOS/buffybox/-/merge_requests/87
    */

    (fetchpatch {
      hash = "sha256-GUk+YrG07hL+0w70qvymPzHGTmUXdfzG4Cy35gg/Asw=";
      name = "fix-32-bit-build";
      url = "https://gitlab.postmarketos.org/postmarketOS/buffybox/-/merge_requests/87.patch";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
  ];

  buildInputs = [
    inih
    libdrm
    libinput
    libxkbcommon
  ];

  mesonFlags = [
    (lib.mesonBool "systemd" true)
  ];

  env.PKG_CONFIG_SYSTEMD_SYSTEMD_SYSTEM_UNIT_DIR = "${placeholder "out"}/lib/systemd/system";

  depsBuildBuild = [
    pkg-config
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Suite of graphical applications for the terminal";
    homepage = "https://gitlab.postmarketos.org/postmarketOS/buffybox";
    changelog = "https://gitlab.postmarketos.org/postmarketOS/buffybox/-/blob/main/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ colinsane ];
    platforms = lib.platforms.linux;
  };
})
