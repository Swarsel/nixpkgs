{
  lib,
  stdenv,
  fetchFromGitHub,
  # nativeBuildInputs
  cmake,
  # buildInputs
  glfw3,
  imgui,
  libGLU,
  libglut,
  libx11,
  libxcursor,
  libxi,
  libxinerama,
  libxrandr,
  nix-update-script,
  pkg-config,
  replaceVars,
  xorgproto,
}:

let
  inherit (lib) cmakeBool;

in
stdenv.mkDerivation (finalAttrs: {
  pname = "box2d";
  version = "3.1.1";

  src = fetchFromGitHub {
    owner = "erincatto";
    repo = "box2d";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IqQy9A8fWLG9H8ZPmOXeFZDaaks84miRuzXaFlNwm0g=";
  };

  patches = [
    # prevent CMake from trying to download some libraries from the internet
    (replaceVars ./cmake_dont_fetch_enkits.patch {
      enkits_src = fetchFromGitHub {
        hash = "sha256-CerLj/WY+J3mrMvv7dGmZltjAM9v5C/IY4X+Ph78HVs=";
        owner = "dougbinks";
        repo = "enkiTS";
        rev = "686d0ec31829e0d9e5edf9ceb68c40f9b9b20ea9";
      };
    })
    ./cmake_use_system_glfw_and_imgui.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    glfw3
    (imgui.override {
      # GLFW backend is disabled by default on darwin but box2d imports it unconditionally
      # https://github.com/erincatto/box2d/blob/v3.1.0/samples/main.cpp#L28
      IMGUI_BUILD_GLFW_BINDING = true;
    })
    libGLU
    libx11
    libxcursor
    libxi
    libxinerama
    libxrandr
    libglut
    xorgproto
  ];

  cmakeFlags = [
    (cmakeBool "BOX2D_BUILD_UNIT_TESTS" finalAttrs.finalPackage.doCheck)
  ];

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals stdenv.cc.isGNU [
      # error: '*(float *)((char *)&localPointA + offsetof(b2Vec2, y))' may be used uninitialized
      "-Wno-error=maybe-uninitialized"
    ]
  );

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "2D physics engine";
    homepage = "https://box2d.org/";
    changelog = "https://github.com/erincatto/box2d/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.unix;
  };
})
