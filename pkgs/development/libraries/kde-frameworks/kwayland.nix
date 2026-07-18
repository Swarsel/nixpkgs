{
  lib,
  cmake,
  extra-cmake-modules,
  fetchpatch,
  kdePackages,
  mkDerivation,
  pkg-config,
  qtbase,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

mkDerivation {
  pname = "kwayland";

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    (fetchpatch {
      hash = "sha256-TB9ZIYV58E41rA8mP5MXjIKZUOdH/rZfOYsgUlV+QLk=";
      url = "https://invent.kde.org/plasma/kwayland/-/commit/0954a179d4ef72597efea44a91071eb9a55a385f.diff";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    extra-cmake-modules
    wayland-scanner
  ];

  buildInputs = [
    kdePackages.plasma-wayland-protocols
    wayland
    wayland-protocols
  ];

  propagatedBuildInputs = [ qtbase ];
  meta.platforms = lib.platforms.linux ++ lib.platforms.freebsd;
}
