{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  gi-docgen,
  gjs,
  glib,
  gnome,
  gobject-introspection,
  lua5_1,
  meson,
  ninja,
  pkg-config,
  pkgsCross,
  python3,
  replaceVars,
  spidermonkey_140,
  vala,
}:

let
  luaEnv = lua5_1.withPackages (ps: with ps; [ lgi ]);
in
stdenv.mkDerivation rec {
  pname = "libpeas";
  version = "2.2.1";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    hash = "sha256-WJ7KibQ3AG7fN1VHjfA3x0CiqEz6XSAtutYJXoKOJIg=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  patches = [
    # Make PyGObject’s gi library available.
    (replaceVars ./fix-paths.patch {
      pythonPaths = lib.concatMapStringsSep ", " (pkg: "'${pkg}/${python3.sitePackages}'") [
        python3.pkgs.pygobject3
      ];
    })
  ];

  postPatch = ''
    # Checks lua51 and lua5.1 executable but we have none of them.
    # Then it tries to invoke lua to check for LGI, which requires emulation for cross.
    substituteInPlace meson.build \
      --replace-fail \
        "find_program('lua51', required: false)" \
        "find_program('${lib.getExe' lua5_1 "lua"}', required: false)" \
      --replace-fail \
        "run_command(lua_prg, [" \
        "run_command('${stdenv.hostPlatform.emulator buildPackages}', [lua_prg, "
  '';

  strictDeps = true;

  nativeBuildInputs = [
    gi-docgen
    gobject-introspection
    meson
    ninja
    pkg-config
    vala
  ];

  buildInputs = [
    gjs
    glib
    luaEnv
    python3
    python3.pkgs.pygobject3
    spidermonkey_140
  ];

  propagatedBuildInputs = [
    # Required by libpeas-2.pc
    glib
  ];

  mesonFlags = [
    "-Dgtk_doc=true"
    "-Dvapi=true"
  ];

  # required for locating lua dependencies at build time (when cross compiling):
  env.LUA_CPATH = "${luaEnv}/lib/lua/${luaEnv.luaversion}/?.so";
  env.LUA_PATH = "${luaEnv}/share/lua/${luaEnv.luaversion}/?.lua";

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  depsBuildBuild = [
    pkg-config
  ];

  passthru = {
    tests.cross = pkgsCross.aarch64-multiplatform.libpeas2;

    updateScript = gnome.updateScript {
      attrPath = "libpeas2";
      packageName = "libpeas";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "GObject-based plugins engine";
    homepage = "https://gitlab.gnome.org/GNOME/libpeas";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
}
