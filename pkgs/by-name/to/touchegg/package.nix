{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  cmake,
  fetchpatch,
  gtk3-x11,
  libinput,
  libpthread-stubs,
  libx11,
  libxcb,
  libxdmcp,
  libxi,
  libxrandr,
  libxtst,
  nix-update-script,
  pkg-config,
  pugixml,
  systemd,
  withPantheon ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "touchegg";
  version = "2.0.18";

  src = fetchFromGitHub {
    owner = "JoseExposito";
    repo = "touchegg";
    tag = finalAttrs.version;
    hash = "sha256-7LJ5gD2e6e4edKDabqmsiXTdNKJ39557Q4sEGWF8H1U=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-q/rKXLN8wqisw3QfqEtu1ZaJonOYzkYLFRECNYB620g=";
      name = "cmake-4-support.patch";
      url = "https://github.com/JoseExposito/touchegg/commit/953c4227253d91c73f5ce46f89947262ebf45b18.patch";
    })
  ]
  ++ lib.optionals withPantheon [
    # Required for the next patch to apply
    # Reverts https://github.com/JoseExposito/touchegg/pull/603
    (fetchpatch {
      hash = "sha256-qbWwmEzVXvDAhhrGvMkKN4YNtnFfRW+Yra+i6VEQX4g=";
      revert = true;
      url = "https://github.com/JoseExposito/touchegg/commit/34e947181d84620021601e7f28deb1983a154da8.patch";
    })
    # Disable per-application gesture by default to make sure the default
    # config does not conflict with Pantheon switchboard settings.
    (fetchpatch {
      hash = "sha256-ZOGVkxiXoTORXC6doz5r9IObAbYjhsDjgg3HtzlTSUc=";
      url = "https://github.com/elementary/os-patches/commit/7d9b133e02132d7f13cf2fe850b2fe4c015c3c5e.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs = [
    systemd
    libinput
    pugixml
    cairo
    gtk3-x11
    libx11
    libxtst
    libxrandr
    libxi
    libxdmcp
    libpthread-stubs
    libxcb
  ];

  env.PKG_CONFIG_SYSTEMD_SYSTEMDSYSTEMUNITDIR = "${placeholder "out"}/lib/systemd/system";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Linux multi-touch gesture recognizer";
    homepage = "https://github.com/JoseExposito/touchegg";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "touchegg";
    teams = [ lib.teams.pantheon ];
  };
})
