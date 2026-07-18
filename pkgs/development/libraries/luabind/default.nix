{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  lua,
}:

stdenv.mkDerivation {
  pname = "luabind";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "Oberon00";
    repo = "luabind";
    rev = "49814f6b47ed99e273edc5198a6ebd7fa19e813a";
    sha256 = "sha256-JcOsoQHRvdzF2rsZBW6egOwIy7+7C4wy0LiYmbV590Q";
  };

  patches = [ ./0.9.1-discover-luajit.patch ];

  # CMake 2.8.3 is deprecated and is no longer supported by CMake > 4
  # https://github.com/NixOS/nixpkgs/issues/445447
  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail \
      "cmake_minimum_required(VERSION 2.8.3)" \
      "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [ cmake ];
  buildInputs = [ boost ];
  propagatedBuildInputs = [ lua ];

  passthru = {
    inherit lua;
  };

  meta = {
    description = "Library that helps you create bindings between C++ and Lua";
    homepage = "https://github.com/Oberon00/luabind";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
