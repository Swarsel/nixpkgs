{
  lib,
  stdenv,
  cmake,
  fixDarwinDylibNames,
  isLuaJIT,
  libuv,
  lua,
}:

stdenv.mkDerivation {
  inherit (lua.pkgs.luv) version src meta;
  pname = "libluv";

  nativeBuildInputs = [
    cmake
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ fixDarwinDylibNames ];

  buildInputs = [
    libuv
    lua
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DBUILD_MODULE=OFF"
    "-DWITH_SHARED_LIBUV=ON"
    "-DLUA_BUILD_TYPE=System"
    "-DWITH_LUA_ENGINE=${if isLuaJIT then "LuaJit" else "Lua"}"
  ];

  # to make sure we dont use bundled deps
  prePatch = ''
    rm -rf deps/lua deps/luajit deps/libuv
  '';

  passthru.tests = {
    # Test luv too
    luv = lua.pkgs.luv.passthru.tests.test;
  };
}
