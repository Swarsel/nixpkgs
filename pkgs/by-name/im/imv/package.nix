{
  lib,
  stdenv,
  asciidoc,
  cmocka,
  docbook_xsl,
  fetchFromSourcehut,
  icu,
  inih,
  libGL,
  libheif,
  libjpeg_turbo,
  libjxl,
  libnsbmp,
  libnsgif,
  libpng,
  librsvg,
  libtiff,
  libwebp,
  libx11,
  libxcb,
  libxkbcommon,
  libxslt,
  meson,
  ninja,
  pango,
  pkg-config,
  qoi,
  tinyxxd,
  versionCheckHook,
  wayland,
  wayland-protocols,
  wayland-scanner,
  withBackends ? [
    "farbfeld"
    "libjxl"
    "libtiff"
    "libjpeg"
    "libpng"
    "librsvg"
    "libheif"
    "libnsgif"
    "libnsbmp"
    "libwebp"
    "qoi"
  ],
  withWindowSystem ? if stdenv.hostPlatform.isLinux then "all" else "x11",
}:

let
  windowSystems = {
    all = windowSystems.x11 ++ windowSystems.wayland;

    wayland = [
      wayland
      wayland-scanner
      wayland-protocols
    ];

    x11 = [
      libxcb
      libx11
    ];
  };

  backends = {
    inherit
      libtiff
      libpng
      librsvg
      libheif
      libjxl
      libnsgif
      libnsbmp
      libwebp
      qoi
      ;

    farbfeld = null; # builtin
    libjpeg = libjpeg_turbo;
  };

  backendFlags = map (b: lib.mesonEnable b (lib.elem b withBackends)) (lib.attrNames backends);
in

# check that given window system is valid
assert lib.assertOneOf "withWindowSystem" withWindowSystem (builtins.attrNames windowSystems);
# check that every given backend is valid
assert builtins.all (
  b: lib.assertOneOf "each backend" b (builtins.attrNames backends)
) withBackends;

stdenv.mkDerivation (finalAttrs: {
  pname = "imv";
  version = "5.0.1";

  src = fetchFromSourcehut {
    owner = "~exec64";
    repo = "imv";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2JTs/hj6t9wEZKoUpcLDFulbdU/grDlQkuEAE7uayDs=";
  };

  outputs = [
    "out"
    "man"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    asciidoc
    docbook_xsl
    libxslt
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libGL
    icu
    libxkbcommon
    pango
    inih
  ]
  ++ windowSystems."${withWindowSystem}"
  ++ map (b: backends."${b}") withBackends;

  mesonFlags = [
    (lib.mesonOption "windows" withWindowSystem)
    (lib.mesonEnable "test" finalAttrs.finalPackage.doCheck)
    (lib.mesonEnable "man" true)
  ]
  ++ backendFlags;

  doCheck = true;

  nativeCheckInputs = [
    tinyxxd
  ];

  checkInputs = [
    cmocka
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "-v";

  meta = {
    description = "Command line image viewer for tiling window managers";
    homepage = "https://sr.ht/~exec64/imv/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      rnhmjoj
      markus1189
    ];

    platforms = lib.platforms.all;
    badPlatforms = lib.platforms.darwin;
    mainProgram = "imv";
  };
})
