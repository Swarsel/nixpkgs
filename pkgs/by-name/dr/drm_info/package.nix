{
  lib,
  stdenv,
  fetchFromGitLab,
  json_c,
  libdisplay-info,
  libdrm,
  meson,
  ninja,
  nix-update-script,
  pciutils,
  pkg-config,
  scdoc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "drm_info";
  version = "2.10.0";

  src = fetchFromGitLab {
    owner = "emersion";
    repo = "drm_info";
    rev = "v${finalAttrs.version}";
    hash = "sha256-QKF0frDPelwHOzf3r0tzSo7i1WfGhcFGJfxf2bj1+OE=";
    domain = "gitlab.freedesktop.org";
  };

  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail "'<2.4.134'" "'<2.4.133'"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
  ];

  buildInputs = [
    libdrm
    libdisplay-info
    json_c
    pciutils
  ];

  depsBuildBuild = [
    pkg-config
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Small utility to dump info about DRM devices";
    homepage = "https://gitlab.freedesktop.org/emersion/drm_info";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kiskae ];
    platforms = lib.platforms.linux;
    mainProgram = "drm_info";
  };
})
