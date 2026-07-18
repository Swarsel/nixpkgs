{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  freetype,
  libuuid,
  libx11,
  ninja,
  ogre-next,
  ois,
  pkg-config,
}:
stdenv.mkDerivation {
  pname = "mygui";
  version = "0-unstable-2024-02-01";

  src = fetchFromGitHub {
    owner = "cryham";
    repo = "mygui-next";
    rev = "a1490ffe01d503c31a00d8277007ffcb27a4258e";
    hash = "sha256-R80rTsbmkYtrjIYqdYmbfciEM4rtEzLtsM4XfShJwns=";
  };

  patches = [ ./mygui-use-pkg-config-for-ogre-next.patch ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'cmake_minimum_required(VERSION 2.6)' \
                     'cmake_minimum_required(VERSION 3.10)'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    ninja
  ];

  buildInputs = [
    boost
    freetype
    libuuid
    ois
    ogre-next
    libx11
  ];

  cmakeFlags = [
    (lib.cmakeBool "MYGUI_BUILD_DEMOS" false)
    (lib.cmakeBool "MYGUI_BUILD_TOOLS" false)
    (lib.cmakeBool "MYGUI_DONT_USE_OBSOLETE" true)
    (lib.cmakeFeature "MYGUI_RENDERSYSTEM" "8")
  ];

  __structuredAttrs = true;

  meta = {
    description = "Library for creating GUIs for games and 3D applications (Stunt Rally fork)";
    homepage = "http://mygui.info/";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
