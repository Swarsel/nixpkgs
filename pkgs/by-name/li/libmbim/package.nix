{
  lib,
  stdenv,
  fetchFromGitLab,
  bash,
  bash-completion,
  buildPackages,
  glib,
  gobject-introspection,
  help2man,
  meson,
  ninja,
  pkg-config,
  python3,
  withDocs ? stdenv.hostPlatform == stdenv.buildPlatform,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libmbim";
  version = "1.34.0";

  src = fetchFromGitLab {
    owner = "mobile-broadband";
    repo = "libmbim";
    rev = finalAttrs.version;
    hash = "sha256-NhSjW1ZK4XFv7L/IaoTjN5ojwjTDQa178k73zoaneuE=";
    domain = "gitlab.freedesktop.org";
  };

  outputs = [
    "out"
    "dev"
  ]
  ++ lib.optionals withDocs [ "man" ];

  postPatch = ''
    patchShebangs \
      build-aux/mbim-codegen/mbim-codegen
  '';

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
  ]
  ++ lib.optionals withDocs [
    help2man
  ]
  ++ lib.optionals withIntrospection [
    gobject-introspection
  ];

  buildInputs = [
    glib
    bash-completion
    bash
  ];

  mesonFlags = [
    "-Dudevdir=${placeholder "out"}/lib/udev"
    (lib.mesonBool "introspection" withIntrospection)
    (lib.mesonBool "man" withDocs)
  ];

  doCheck = true;

  meta = {
    description = "Library for talking to WWAN modems and devices which speak the Mobile Interface Broadband Model (MBIM) protocol";
    homepage = "https://www.freedesktop.org/wiki/Software/libmbim/";
    changelog = "https://gitlab.freedesktop.org/mobile-broadband/libmbim/-/raw/${finalAttrs.version}/NEWS";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.freedesktop ];
  };
})
