{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  boost,
  cmake,
  fcitx5,
  kdePackages,
  pkg-config,
  python3,
  zstd,
}:

let
  tableVer = "20240108";
  table = fetchurl {
    hash = "sha256-Pp2HsEo5PxMXI0csjqqGDdI8N4o9T2qQBVE7KpWzYUs=";
    url = "https://download.fcitx-im.org/data/table-${tableVer}.tar.zst";
  };
  arpaVer = "20250113";
  arpa = fetchurl {
    hash = "sha256-7oPs8g1S6LzNukz2zVcYPVPCV3E6Xrd+46Y9UPw3lt0=";
    url = "https://download.fcitx-im.org/data/lm_sc.arpa-${arpaVer}.tar.zst";
  };
  dictVer = "20250327";
  dict = fetchurl {
    hash = "sha256-fKa+R1TA1MJ7p3AsDc5lFlm9LKH6pcvyhI2BoAU8jBM=";
    url = "https://download.fcitx-im.org/data/dict-${dictVer}.tar.zst";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "libime";
  version = "1.1.14";

  src = fetchFromGitHub {
    owner = "fcitx";
    repo = "libime";
    tag = finalAttrs.version;
    hash = "sha256-q9OSY1q4MNlFqw6lRMrHO6QT9xP8Czz4b4M0BuIkp34=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.extra-cmake-modules
    python3
  ];

  buildInputs = [
    zstd
    boost
    fcitx5
  ];

  prePatch = ''
    ln -s ${table} data/$(stripHash ${table})
    ln -s ${arpa} data/$(stripHash ${arpa})
    ln -s ${dict} data/$(stripHash ${dict})
  '';

  meta = {
    description = "Library to support generic input method implementation";
    homepage = "https://github.com/fcitx/libime";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ poscat ];
    platforms = lib.platforms.linux;
  };
})
