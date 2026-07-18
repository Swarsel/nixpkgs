{
  autoPatchelfHook,
  cairo,
  fontconfig,
  freetype,
  glib,
  gtk2,
  gtk3,
  libdrm,
  libgbm,
  libintl,
  libx11,
  libxext,
  mkDerivation,
  nvidia-driver,
  pango,
}:
mkDerivation {
  inherit (nvidia-driver) src version;
  pname = "nvidia-libs";

  postPatch = ''
    substituteInPlace lib/libGLX_nvidia/Makefile \
      --replace-fail /usr/share/nvidia $out/share/nvidia \
      --replace-fail " '''" ""
  '';

  buildInputs = [
    libdrm
    libgbm
    gtk2
    gtk3
    cairo
    pango
    fontconfig
    glib
    libintl
    freetype
    libxext
    libx11
  ];

  env.EGL_EXTERNAL_PLATFORM_JSON_PATH = "${builtins.placeholder "out"}/share/egl/egl_external_platform.d";
  env.EGL_GLVND_JSON_PATH = "${builtins.placeholder "out"}/share/glvnd/egl_vendor.d";
  env.LOCALBASE = "${builtins.placeholder "out"}";
  env.VKICD_PATH = "${builtins.placeholder "out"}/share/vulkan/icd.d";
  env.VKLAYERS_PATH = "${builtins.placeholder "out"}/share/vulkan/implicit_layer.d";

  installPhase = ''
    make -C lib install
  '';

  dontBuild = true;

  extraNativeBuildInputs = [
    autoPatchelfHook
  ];

  path = "...";
}
