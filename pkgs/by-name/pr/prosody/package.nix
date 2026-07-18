{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  fetchhg,
  icu,
  libidn,
  lua,
  makeWrapper,
  nixosTests,
  openssl,
  withCommunityModules ? [ ],
  withDBI ? true,
  # use withExtraLibs to add additional dependencies of community modules
  withExtraLibs ? [ ],
  withExtraLuaPackages ? _: [ ],
  withOnlyInstalledCommunityModules ? [ ],
}:

let
  luaEnv = lua.withPackages (
    p:
    with p;
    [
      luasocket
      luasec
      luaexpat
      luafilesystem
      luabitop
      luadbi-sqlite3
      luaunbound
    ]
    ++ lib.optional withDBI p.luadbi
    ++ withExtraLuaPackages p
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "prosody";
  version = "13.0.6"; # also update communityModules

  src = fetchurl {
    url = "https://prosody.im/downloads/source/prosody-${finalAttrs.version}.tar.gz";
    hash = "sha256-7GlvnPViw69KBLB9P7NqHO3MTmmjkv3c/FJLxn2TBQ8=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    luaEnv
    libidn
    openssl
    icu
  ]
  ++ withExtraLibs;

  configureFlags = [
    "--ostype=linux"
    "--with-lua-bin=${lib.getBin buildPackages.lua}/bin"
    "--with-lua-include=${luaEnv}/include"
    "--with-lua=${luaEnv}"
    "--c-compiler=${stdenv.cc.targetPrefix}cc"
    "--linker=${stdenv.cc.targetPrefix}cc"
  ];

  buildFlags = [
    # don't search for configs in the nix store when running prosodyctl
    "INSTALLEDCONFIG=/etc/prosody"
    "INSTALLEDDATA=/var/lib/prosody"
  ];

  postBuild = ''
    make -C tools/migration
  '';

  # the wrapping should go away once lua hook is fixed
  postInstall = ''
    ${lib.concatMapStringsSep "\n"
      (module: ''
        cp -r ${finalAttrs.communityModules}/mod_${module} $out/lib/prosody/modules/
      '')
      (
        lib.lists.unique (
          finalAttrs.nixosModuleDeps ++ withCommunityModules ++ withOnlyInstalledCommunityModules
        )
      )
    }
    make -C tools/migration install
  '';

  # A note to all those merging automated updates: Please also update this
  # attribute as some modules might not be compatible with a newer prosody
  # version.
  communityModules = fetchhg {
    hash = "sha256-RvhPV6YMdwxxIeHhpqXPfBh6087PAPAQV8D+stpXmBs=";
    rev = "15a7749c7acb";
    url = "https://hg.prosody.im/prosody-modules";
  };

  configurePlatforms = [ ];

  # The following community modules are necessary for the nixos module
  # prosody module to comply with XEP-0423 and provide a working
  # default setup.
  nixosModuleDeps = [
    "cloud_notify"
  ];

  passthru = {
    communityModules = withCommunityModules;
    tests = { inherit (nixosTests) prosody prosody-mysql; };
  };

  meta = {
    description = "Open-source XMPP application server written in Lua";
    homepage = "https://prosody.im";
    changelog = "https://prosody.im/doc/release/${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      toastal
      mirror230469
      SuperSandro2000
    ];

    platforms = lib.platforms.linux;
    mainProgram = "prosody";
  };
})
