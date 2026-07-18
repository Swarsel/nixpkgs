{
  lib,
  stdenv,
  fetchurl,
  hash,
  makeWrapper,
  passthruFun,
  pkgsBuildBuild,
  pkgsBuildHost,
  pkgsBuildTarget,
  pkgsHostHost,
  pkgsTargetTarget,
  readline,
  replaceVars,
  self,
  version,
  compat ? false,
  luaAttr ? "lua${lib.versions.major version}_${lib.versions.minor version}",
  packageOverrides ? (final: prev: { }),
  patches ? [ ],
  postBuild ? null,
  postConfigure ? null,
  staticOnly ? stdenv.hostPlatform.isStatic,
}@inputs:

stdenv.mkDerivation (
  finalAttrs:
  let
    luaPackages = self.pkgs;

    luaversion = lib.versions.majorMinor finalAttrs.version;

    plat =
      if (stdenv.hostPlatform.isLinux && self.luaversion == "5.4") then
        "linux-readline"
      else if stdenv.hostPlatform.isLinux then
        "linux"
      else if stdenv.hostPlatform.isDarwin then
        "macosx"
      else if stdenv.hostPlatform.isMinGW then
        "mingw"
      else if stdenv.hostPlatform.isFreeBSD then
        "freebsd"
      else if stdenv.hostPlatform.isSunOS then
        "solaris"
      else if stdenv.hostPlatform.isBSD then
        "bsd"
      else if stdenv.hostPlatform.isUnix then
        "posix"
      else
        "generic";

    compatFlags =
      if (lib.versionOlder self.luaversion "5.3") then
        " -DLUA_COMPAT_ALL"
      else if (lib.versionOlder self.luaversion "5.4") then
        " -DLUA_COMPAT_5_1 -DLUA_COMPAT_5_2"
      else
        " -DLUA_COMPAT_5_3";
  in

  {
    inherit version;
    inherit patches;
    inherit postConfigure;
    inherit postBuild;
    pname = "lua";

    src = fetchurl {
      url = "https://www.lua.org/ftp/lua-${finalAttrs.version}.tar.gz";
      sha256 = hash;
    };

    outputs = [
      "out"
      "doc"
    ];

    postPatch = ''
      sed -i "s@#define LUA_ROOT[[:space:]]*\"/usr/local/\"@#define LUA_ROOT  \"$out/\"@g" src/luaconf.h

      # abort if patching didn't work
      grep $out src/luaconf.h
    ''
    + lib.optionalString (!stdenv.hostPlatform.isDarwin && !staticOnly) ''
      # Add a target for a shared library to the Makefile.
      sed -e '1s/^/LUA_SO = liblua.so/' \
          -e 's/ALL_T *= */&$(LUA_SO) /' \
          -i src/Makefile
      cat ${./lua-dso.make} >> src/Makefile
    '';

    nativeBuildInputs = [ makeWrapper ];
    buildInputs = [ readline ];

    # see configurePhase for additional flags (with space)
    makeFlags = [
      "INSTALL_TOP=${placeholder "out"}"
      "INSTALL_MAN=${placeholder "out"}/share/man/man1"
      "R=${version}"
      "LDFLAGS=-fPIC"
      "V=${luaversion}"
      "PLAT=${plat}"
      "CC=${stdenv.cc.targetPrefix}cc"
      "RANLIB=${stdenv.cc.targetPrefix}ranlib"
      # Lua links with readline which depends on ncurses. For some reason when
      # building pkgsStatic.lua it fails because symbols from ncurses are not
      # found. Adding ncurses here fixes the problem.
      "MYLIBS=-lncurses"
    ];

    env = {
      inherit luaversion;
      pkgversion = version;
    };

    postInstall = ''
      mkdir -p "$out/nix-support" "$out/share/doc/lua" "$out/lib/pkgconfig"
      cp ${
        replaceVars ./utils.sh {
          luacpathsearchpaths = lib.escapeShellArgs finalAttrs.LuaCPathSearchPaths;
          luapathsearchpaths = lib.escapeShellArgs finalAttrs.LuaPathSearchPaths;
        }
      } $out/nix-support/utils.sh
      mv "doc/"*.{gif,png,css,html} "$out/share/doc/lua/"
      rmdir $out/{share,lib}/lua/${luaversion} $out/{share,lib}/lua
      mkdir -p "$out/lib/pkgconfig"

      cat >"$out/lib/pkgconfig/lua.pc" <<EOF
      prefix=$out
      libdir=$out/lib
      includedir=$out/include
      INSTALL_BIN=$out/bin
      INSTALL_INC=$out/include
      INSTALL_LIB=$out/lib
      INSTALL_MAN=$out/man/man1

      Name: Lua
      Description: An Extensible Extension Language
      Version: ${finalAttrs.version}
      Requires:
      Libs: -L$out/lib -llua
      Cflags: -I$out/include
      EOF
      ln -s "$out/lib/pkgconfig/lua.pc" "$out/lib/pkgconfig/lua-${luaversion}.pc"
      ln -s "$out/lib/pkgconfig/lua.pc" "$out/lib/pkgconfig/lua${luaversion}.pc"
      ln -s "$out/lib/pkgconfig/lua.pc" "$out/lib/pkgconfig/lua${
        lib.replaceStrings [ "." ] [ "" ] luaversion
      }.pc"

      # Make documentation outputs of different versions co-installable.
      mv $out/share/doc/lua $out/share/doc/lua-${finalAttrs.version}
    '';

    LuaCPathSearchPaths = luaPackages.luaLib.luaCPathList;
    LuaPathSearchPaths = luaPackages.luaLib.luaPathList;

    configurePhase = ''
      runHook preConfigure

      makeFlagsArray+=(CFLAGS='-O2 -fPIC${lib.optionalString compat compatFlags} $(${
        if lib.versionAtLeast luaversion "5.2" then "SYSCFLAGS" else "MYCFLAGS"
      })' )
      makeFlagsArray+=(${lib.optionalString stdenv.hostPlatform.isDarwin "CC=\"$CC\""}${
        lib.optionalString (
          stdenv.buildPlatform != stdenv.hostPlatform
        ) " 'AR=${stdenv.cc.targetPrefix}ar rcu'"
      })

      installFlagsArray=( TO_BIN="lua luac" INSTALL_DATA='cp -d' \
        TO_LIB="${
          if stdenv.hostPlatform.isDarwin then
            "liblua.${finalAttrs.version}.dylib"
          else
            (
              "liblua.a"
              + lib.optionalString (
                !staticOnly
              ) " liblua.so liblua.so.${luaversion} liblua.so.${finalAttrs.version}"
            )
        }" )

      runHook postConfigure
    '';

    setupHook = builtins.toFile "lua-setup-hook" ''
      source @out@/nix-support/utils.sh
      addEnvHooks "$hostOffset" luaEnvHook
    '';

    # copied from python
    passthru =
      let
        # When we override the interpreter we also need to override the spliced versions of the interpreter
        inputs' = lib.filterAttrs (n: v: !lib.isDerivation v && n != "passthruFun") inputs;
        override =
          attr:
          let
            lua = attr.override (inputs' // { self = lua; });
          in
          lua;
      in
      passthruFun rec {
        inherit
          self
          luaversion
          packageOverrides
          luaAttr
          ;

        executable = "lua";
        luaOnBuildForBuild = override pkgsBuildBuild.${luaAttr};
        luaOnBuildForHost = override pkgsBuildHost.${luaAttr};
        luaOnBuildForTarget = override pkgsBuildTarget.${luaAttr};
        luaOnHostForHost = override pkgsHostHost.${luaAttr};

        luaOnTargetForTarget = lib.optionalAttrs (lib.hasAttr luaAttr pkgsTargetTarget) (
          override pkgsTargetTarget.${luaAttr}
        );
      };

    meta = {
      description = "Powerful, fast, lightweight, embeddable scripting language";

      longDescription = ''
        Lua combines simple procedural syntax with powerful data
        description constructs based on associative arrays and extensible
        semantics. Lua is dynamically typed, runs by interpreting bytecode
        for a register-based virtual machine, and has automatic memory
        management with incremental garbage collection, making it ideal
        for configuration, scripting, and rapid prototyping.
      '';

      homepage = "https://www.lua.org";
      license = lib.licenses.mit;
      platforms = lib.platforms.unix;
      mainProgram = "lua";
    };
  }
)
