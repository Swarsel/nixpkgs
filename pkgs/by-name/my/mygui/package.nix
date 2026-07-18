{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  fetchpatch,
  freetype,
  libGL,
  libGLU,
  libuuid,
  libx11,
  ogre,
  ois,
  pkg-config,
  withOgre ? false,
}:

let
  renderSystem = if withOgre then "3" else "4";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "mygui";
  version = "3.4.3";

  src = fetchFromGitHub {
    owner = "MyGUI";
    repo = "mygui";
    tag = "MyGUI${finalAttrs.version}";
    hash = "sha256-qif9trHgtWpYiDVXY3cjRsXypjjjgStX8tSWCnXhXlk=";
  };

  patches = [
    (fetchpatch {
      name = "darwin-mygui-framework-fix.patch";
      sha256 = "sha256-Tk+O4TFgPZOqWAY4c0Q69bZfvIB34wN9e7h0tXhLULU=";
      url = "https://gitlab.com/OpenMW/openmw-dep/-/raw/ade30e6e98c051ac2a505f6984518f5f41fa87a5/macos/mygui.patch";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    boost
    freetype
    libuuid
    ois
  ]
  ++ lib.optionals withOgre [
    ogre
  ]
  ++ lib.optionals (!withOgre && stdenv.hostPlatform.isLinux) [
    libGL
    libGLU
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libx11
  ];

  # Tools are disabled due to compilation failures.
  cmakeFlags = [
    (lib.cmakeBool "MYGUI_BUILD_DEMOS" false)
    (lib.cmakeBool "MYGUI_BUILD_TOOLS" false)
    (lib.cmakeBool "MYGUI_DONT_USE_OBSOLETE" true)
    (lib.cmakeFeature "MYGUI_RENDERSYSTEM" renderSystem)
  ];

  __structuredAttrs = true;

  meta = {
    description = "Library for creating GUIs for games and 3D applications";
    homepage = "http://mygui.info/";
    changelog = "https://github.com/MyGUI/mygui/releases/tag/MyGUI${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmasquadron ];
    platforms = lib.platforms.unix;
    # error: implicit instantiation of undefined template 'std::char_traits'
    badPlatforms = lib.platforms.darwin;
  };
})
