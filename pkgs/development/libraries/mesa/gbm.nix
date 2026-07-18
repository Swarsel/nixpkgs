{
  lib,
  stdenv,
  fetchFromGitLab,
  bison,
  flex,
  libdrm,
  libglvnd,
  meson,
  ninja,
  pkg-config,
  python3Packages,
}:

let
  common = import ./common.nix { inherit lib fetchFromGitLab; };
in
stdenv.mkDerivation rec {
  inherit (common) meta;
  pname = "mesa-libgbm";
  # We don't use the versions from common.nix, because libgbm is a world rebuild,
  # so the updates need to happen separately on staging.
  version = "26.1.3";

  src = fetchFromGitLab {
    owner = "mesa";
    repo = "mesa";
    rev = "mesa-${version}";
    hash = "sha256-W2Ud9wmiIuDYMnFj8sK2SGAI1WayMCtdj7/7od/1Ql4=";
    domain = "gitlab.freedesktop.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    bison
    flex
    meson
    pkg-config
    ninja
    python3Packages.packaging
    python3Packages.python
    python3Packages.mako
    python3Packages.pyyaml
  ];

  propagatedBuildInputs = [ libdrm ];

  mesonFlags = [
    "--sysconfdir=/etc"

    (lib.mesonEnable "gbm" true)
    (lib.mesonOption "gbm-backends-path" "${libglvnd.driverLink}/lib/gbm")

    (lib.mesonEnable "egl" false)
    (lib.mesonEnable "glx" false)
    (lib.mesonEnable "zlib" false)

    (lib.mesonOption "platforms" "")
    (lib.mesonOption "gallium-drivers" "")
    (lib.mesonOption "vulkan-drivers" "")
    (lib.mesonOption "vulkan-layers" "")
  ];

  mesonAutoFeatures = "disabled";
}
