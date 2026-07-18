{
  lib,
  stdenv,
  fetchFromGitLab,
  fetchpatch,
  lcms2,
  libGL,
  libdovi,
  libunwind,
  libx11,
  meson,
  ninja,
  pkg-config,
  python3Packages,
  shaderc,
  vulkan-headers,
  vulkan-loader,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libplacebo";
  version = "5.264.1";

  src = fetchFromGitLab {
    owner = "videolan";
    repo = "libplacebo";
    rev = "v${finalAttrs.version}";
    hash = "sha256-YEefuEfJURi5/wswQKskA/J1UGzessQQkBpltJ0Spq8=";
    domain = "code.videolan.org";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-RrlFu0xgLB05IVrzL2EViTPuATYXraM1KZMxnZCvgrk=";
      name = "python-compat.patch";
      url = "https://code.videolan.org/videolan/libplacebo/-/commit/12509c0f1ee8c22ae163017f0a5e7b8a9d983a17.patch";
    })
  ];

  postPatch = ''
    substituteInPlace meson.build \
      --replace 'python_env.append' '#'
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vulkan-headers
    python3Packages.jinja2
    python3Packages.glad2
  ];

  buildInputs = [
    vulkan-loader
    shaderc
    lcms2
    libGL
    libx11
    libunwind
    libdovi
  ];

  mesonFlags = [
    (lib.mesonOption "vulkan-registry" "${vulkan-headers}/share/vulkan/registry/vk.xml")
    (lib.mesonBool "demos" false) # Don't build and install the demo programs
    (lib.mesonEnable "d3d11" false) # Disable the Direct3D 11 based renderer
    (lib.mesonEnable "glslang" false) # rely on shaderc for GLSL compilation instead
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    (lib.mesonEnable "unwind" false) # libplacebo doesn’t build with `darwin.libunwind`
  ];

  meta = {
    description = "Reusable library for GPU-accelerated video/image rendering primitives";

    longDescription = ''
      Reusable library for GPU-accelerated image/view processing primitives and
      shaders, as well a batteries-included, extensible, high-quality rendering
      pipeline (similar to mpv's vo_gpu). Supports Vulkan, OpenGL and Metal (via
      MoltenVK).
    '';

    homepage = "https://code.videolan.org/videolan/libplacebo";
    changelog = "https://code.videolan.org/videolan/libplacebo/-/tags/v${finalAttrs.version}";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
