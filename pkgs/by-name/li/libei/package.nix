{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchFromGitLab,
  basu,
  buildPackages,
  epoll-shim,
  evdev-proto,
  fetchpatch,
  libevdev,
  libxkbcommon,
  meson,
  ninja,
  pkg-config,
  protobuf,
  protobufc,
  systemd,
}:
let
  munit = fetchFromGitHub {
    hash = "sha256-qm30C++rpLtxBhOABBzo+6WILSpKz2ibvUvoe8ku4ow=";
    owner = "nemequ";
    repo = "munit";
    rev = "fbbdf1467eb0d04a6ee465def2e529e4c87f2118";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "libei";
  version = "1.6.0";

  src = fetchFromGitLab {
    owner = "libinput";
    repo = "libei";
    rev = finalAttrs.version;
    hash = "sha256-fUeMdRK7uoRvgvY3INMorwnTleLrLA5xOeYBFp1qXeI=";
    domain = "gitlab.freedesktop.org";
  };

  patches = lib.optionals stdenv.hostPlatform.isBSD [
    # From https://gitlab.freedesktop.org/libinput/libei/-/merge_requests/357
    (fetchpatch {
      hash = "sha256-Z6oZphzyfHMdAQninbUvEtxr738sx/SQV8o0fkF25iI=";
      name = "peercred-bsd.patch";
      url = "https://gitlab.freedesktop.org/libinput/libei/-/commit/4f11112be0c0a89e8f078c0b4bcc103dbc6ac875.patch";
    })
  ];

  postPatch = ''
    ln -s "${munit}" ./subprojects/munit
    patchShebangs ./proto/ei-scanner
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    (buildPackages.python3.withPackages (
      ps: with ps; [
        attrs
        jinja2
        pytest
        python-dbusmock
        strenum
        structlog
      ]
    ))
  ];

  buildInputs = [
    libevdev
    libxkbcommon
    protobuf
    protobufc
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    systemd
  ]
  ++ lib.optionals stdenv.hostPlatform.isFreeBSD [
    basu
    epoll-shim
    evdev-proto
  ];

  mesonFlags = lib.optionals stdenv.hostPlatform.isFreeBSD [
    "-Dsd-bus-provider=basu"
  ];

  meta = {
    description = "Library for Emulated Input";
    homepage = "https://gitlab.freedesktop.org/libinput/libei";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.pedrohlc ];
    platforms = lib.platforms.linux ++ lib.platforms.freebsd;
    mainProgram = "ei-debug-events";
  };
})
