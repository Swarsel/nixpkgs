{
  lib,
  fetchFromGitHub,
  cairo,
  cmake,
  file,
  gcc15Stdenv,
  hyprutils,
  lcms2,
  libGL,
  libdrm,
  libjpeg,
  libjxl,
  librsvg,
  libspng,
  libwebp,
  nix-update-script,
  pango,
  pixman,
  pkg-config,
}:

gcc15Stdenv.mkDerivation (finalAttrs: {
  pname = "hyprgraphics";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprgraphics";
    tag = "v${finalAttrs.version}";
    hash = "sha256-48DubZbx8PDfuJkksNgi5aWFnX/Rq1OUaLsUvsdf2Bo=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    cairo
    file
    hyprutils
    lcms2
    libGL
    libdrm
    libjpeg
    libjxl
    librsvg
    libspng
    libwebp
    pango
    pixman
  ];

  doCheck = true;
  cmakeBuildType = "RelWithDebInfo";
  separateDebugInfo = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Cpp graphics library for Hypr* ecosystem";
    homepage = "https://github.com/hyprwm/hyprgraphics";
    changelog = "https://github.com/hyprwm/hyprgraphics/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux ++ lib.platforms.freebsd;
    teams = [ lib.teams.hyprland ];
  };
})
