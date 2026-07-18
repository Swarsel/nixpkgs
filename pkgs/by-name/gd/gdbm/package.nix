{
  lib,
  stdenv,
  fetchurl,
  testers,
  updateAutotoolsGnuConfigScriptsHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gdbm";
  version = "1.26";

  src = fetchurl {
    url = "mirror://gnu/gdbm/gdbm-${finalAttrs.version}.tar.gz";
    hash = "sha256-aiRQShTeSnRBA9y5Nr6Xbfb76IzP8mBl5UwcR5RvSl4=";
  };

  outputs = [
    "out"
    "dev"
    "info"
    "lib"
    "man"
  ];

  # 1. Linking static stubs on cygwin requires correct ordering. Consider
  #    upstreaming this.
  #
  # 2. Disable dbmfetch03.at test because it depends on unlink() failing on a
  #    link in a chmod -w directory, which cygwin apparently allows.
  postPatch = lib.optionalString stdenv.buildPlatform.isCygwin ''
    substituteInPlace tests/Makefile.in \
      --replace-fail '_LDADD = ../src/libgdbm.la ../compat/libgdbm_compat.la' \
                     '_LDADD = ../compat/libgdbm_compat.la ../src/libgdbm.la'
    substituteInPlace tests/testsuite.at
      --replace-fail 'm4_include([dbmfetch03.at])' ""
  '';

  nativeBuildInputs = [ updateAutotoolsGnuConfigScriptsHook ];
  configureFlags = [ (lib.enableFeature true "libgdbm-compat") ];
  doCheck = true;

  # create symlinks for compatibility
  postInstall = ''
    install -dm755 ''${!outputDev}/include/gdbm
    pushd ''${!outputDev}/include/gdbm
    ln -s ../dbm.h dbm.h
    ln -s ../gdbm.h gdbm.h
    ln -s ../ndbm.h ndbm.h
    popd
  '';

  enableParallelBuilding = true;
  hardeningDisable = [ "strictflexarrays3" ];

  passthru = {
    tests.version = testers.testVersion {
      command = "gdbmtool --version";
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "GNU dbm key/value database library";

    longDescription = ''
      GNU dbm (or GDBM, for short) is a library of database functions that use
      extensible hashing and work similar to the standard UNIX dbm. These
      routines are provided to a programmer needing to create and manipulate a
      hashed database.

      The basic use of GDBM is to store key/data pairs in a data file. Each
      key must be unique and each key is paired with only one data item.

      The library provides primitives for storing key/data pairs, searching and
      retrieving the data by its key and deleting a key along with its data.
      It also support sequential iteration over all key/data pairs in a
      database.

      For compatibility with programs using old UNIX dbm function, the package
      also provides traditional dbm and ndbm interfaces.
    '';

    homepage = "https://www.gnu.org/software/gdbm/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "gdbmtool";
  };
})
