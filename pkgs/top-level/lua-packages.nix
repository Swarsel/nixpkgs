/*
  This file defines the composition for Lua packages.  It has
  been factored out of all-packages.nix because there are many of
  them.  Also, because most Nix expressions for Lua packages are
  trivial, most are actually defined here.  I.e. there's no function
  for each package in a separate file: the call to the function would
  be almost as must code as the function itself.
*/

{
  lib,
  stdenv,
  lua,
  pkgs,
}:

self:

let
  inherit (self) callPackage;

  buildLuaApplication = args: buildLuarocksPackage ({ namePrefix = ""; } // args);

  buildLuarocksPackage = lib.makeOverridable (
    callPackage ../development/interpreters/lua-5/build-luarocks-package.nix { }
  );

  luaLib = callPackage ../development/lua-modules/lib.nix { };

  #define build lua package function
  buildLuaPackage = callPackage ../development/lua-modules/generic { };

  getPath =
    drv: pathListForVersion: lib.concatMapStringsSep ";" (path: "${drv}/${path}") pathListForVersion;

in
rec {

  # helper functions for dealing with LUA_PATH and LUA_CPATH
  inherit luaLib;

  inherit (callPackage ../development/interpreters/lua-5/hooks { })
    luarocksMoveDataFolder
    luarocksCheckHook
    bustedCheckHook
    ;

  inherit lua;
  inherit buildLuaPackage buildLuarocksPackage buildLuaApplication;

  inherit (luaLib)
    luaOlder
    luaAtLeast
    isLua51
    isLua52
    isLua53
    isLuaJIT
    requiredLuaModules
    toLuaModule
    hasLuaModule
    ;

  awesome-wm-widgets = callPackage (
    {
      lib,
      stdenv,
      fetchFromGitHub,
      lua,
    }:

    stdenv.mkDerivation {
      pname = "awesome-wm-widgets";
      version = "0-unstable-2024-02-15";

      src = fetchFromGitHub {
        owner = "streetturtle";
        repo = "awesome-wm-widgets";
        rev = "2a27e625056c50b40b1519eed623da253d36cc27";
        hash = "sha256-qz/kUIpuhWwTLbwbaES32wGKe4D2hfz90dnq+mrHrj0=";
      };

      installPhase = ''
        runHook preInstall

        target=$out/lib/lua/${lua.luaversion}/awesome-wm-widgets
        mkdir -p $target
        cp -r $src/* $target

        runHook postInstall
      '';

      meta = {
        description = "Widgets for Awesome window manager";
        homepage = "https://github.com/streetturtle/awesome-wm-widgets";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ averdow ];
      };
    }
  ) { };

  getLuaCPath = drv: getPath drv luaLib.luaCPathList;
  getLuaPath = drv: getPath drv luaLib.luaPathList;
  image-nvim = callPackage ../development/lua-modules/image-nvim { };
  libluv = callPackage ../development/lua-modules/luv/lib.nix { };
  lua-https = callPackage ../development/lua-modules/lua-https { };

  lua-pam = callPackage (
    {
      fetchFromGitHub,
      linux-pam,
      openpam,
    }:
    buildLuaPackage {
      pname = "lua-pam";
      version = "unstable-2015-07-03";

      src = fetchFromGitHub {
        owner = "devurandom";
        repo = "lua-pam";
        rev = "3818ee6346a976669d74a5cbc2a83ad2585c5953";
        hash = "sha256-YlMZ5mM9Ij/9yRmgA0X1ahYVZMUx8Igj5OBvAMskqTg=";
        fetchSubmodules = true;
      };

      buildInputs =
        lib.optionals stdenv.hostPlatform.isLinux [ linux-pam ]
        ++ lib.optionals stdenv.hostPlatform.isDarwin [ openpam ];

      # The makefile tries to link to `-llua<luaversion>`
      env.LUA_LIBS = "-llua";

      installPhase = ''
        runHook preInstall

        install -Dm755 pam.so $out/lib/lua/${lua.luaversion}/pam.so

        runHook postInstall
      '';

      meta = {
        description = "Lua module for PAM authentication";
        homepage = "https://github.com/devurandom/lua-pam";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ traxys ];
        # The package does not build with lua 5.4 or luaJIT
        broken = luaAtLeast "5.4" || isLuaJIT;
      };
    }
  ) { };

  lua-resty-core = callPackage (
    { fetchFromGitHub }:
    buildLuaPackage rec {
      pname = "lua-resty-core";
      version = "0.1.32";

      src = fetchFromGitHub {
        owner = "openresty";
        repo = "lua-resty-core";
        rev = "v${version}";
        sha256 = "sha256-ba/ahIl8BDfyXIbaN6zVCh3UwY6JbAqqZEpXktOfeYo=";
      };

      propagatedBuildInputs = [ lua-resty-lrucache ];

      meta = {
        description = "New FFI-based API for lua-nginx-module";
        homepage = "https://github.com/openresty/lua-resty-core";
        license = lib.licenses.bsd3;
        maintainers = [ ];
      };
    }
  ) { };

  lua-resty-lrucache = callPackage (
    { fetchFromGitHub }:
    buildLuaPackage rec {
      pname = "lua-resty-lrucache";
      version = "0.15";

      src = fetchFromGitHub {
        owner = "openresty";
        repo = "lua-resty-lrucache";
        rev = "v${version}";
        sha256 = "sha256-G2l4Zo9Xm/m4zRfxrgzEvRE5LMO+UuX3kd7FwlCnxDA=";
      };

      meta = {
        description = "Lua-land LRU Cache based on LuaJIT FFI";
        homepage = "https://github.com/openresty/lua-resty-lrucache";
        license = lib.licenses.bsd3;
        maintainers = [ ];
      };
    }
  ) { };

  # Dont take luaPackages from "global" pkgs scope to avoid mixing lua versions
  luaPackages = self;
  # a fork of luarocks used to generate nix lua derivations from rockspecs
  luarocks-nix = toLuaModule (callPackage ../development/tools/misc/luarocks/luarocks-nix.nix { });
  luarocks_bootstrap = toLuaModule (callPackage ../development/tools/misc/luarocks/default.nix { });
  luv = callPackage ../development/lua-modules/luv { };

  luxio = callPackage (
    {
      fetchurl,
      pkg-config,
      which,
    }:
    buildLuaPackage rec {
      pname = "luxio";
      version = "13";

      src = fetchurl {
        url = "https://git.gitano.org.uk/luxio.git/snapshot/luxio-luxio-${version}.tar.bz2";
        sha256 = "1hvwslc25q7k82rxk461zr1a2041nxg7sn3sw3w0y5jxf0giz2pz";
      };

      postPatch = ''
        patchShebangs const-proc.lua
      '';

      nativeBuildInputs = [
        which
        pkg-config
      ];

      preBuild = ''
        makeFlagsArray=(
          INST_LIBDIR="$out/lib/lua/${lua.luaversion}"
          INST_LUADIR="$out/share/lua/${lua.luaversion}"
          LUA_BINDIR="$out/bin"
          INSTALL=install
        );
      '';

      meta = {
        description = "Lightweight UNIX I/O and POSIX binding for Lua";
        homepage = "https://www.gitano.org.uk/luxio/";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ richardipsum ];
        platforms = lib.platforms.unix;
        broken = stdenv.hostPlatform.isDarwin;
      };
    }
  ) { };

  nfd = callPackage ../development/lua-modules/nfd {
    inherit (pkgs) zenity;
  };

  readline = callPackage ../development/lua-modules/readline { inherit (pkgs) readline; };
  # wraps programs in $out/bin with valid LUA_PATH/LUA_CPATH
  wrapLua = callPackage ../development/interpreters/lua-5/wrap-lua.nix { };
}
