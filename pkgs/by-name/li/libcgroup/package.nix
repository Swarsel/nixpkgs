{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bison,
  flex,
  musl-fts,
  pam,
  systemdLibs,
  enablePam ? lib.meta.availableOn stdenv.hostPlatform pam,
  enableSystemd ? lib.meta.availableOn stdenv.hostPlatform systemdLibs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libcgroup";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "libcgroup";
    repo = "libcgroup";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kWW9ID/eYZH0O/Ge8pf3Cso4yu644R5EiQFYfZMcizs=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace src/tools/Makefile.am \
      --replace 'chmod u+s' 'chmod +x'
  '';

  nativeBuildInputs = [
    autoreconfHook
    bison
    flex
  ];

  buildInputs =
    lib.optional enablePam pam
    ++ lib.optional enableSystemd systemdLibs
    ++ lib.optional stdenv.hostPlatform.isMusl musl-fts;

  configureFlags = [
    (lib.enableFeature enablePam "pam")
    (lib.enableFeature enableSystemd "systemd")
  ]
  # implicit declaration of function 'rpl_malloc', ; did you mean 'realloc'
  #
  # It looks like in case of cross-compilation, autoconf assumes that malloc of the
  # target platform is broken.
  ++ lib.optionals (!lib.systems.equals stdenv.buildPlatform stdenv.hostPlatform) [
    "ac_cv_func_malloc_0_nonnull=yes"
    "ac_cv_func_realloc_0_nonnull=yes"
  ];

  meta = {
    description = "Library and tools to manage Linux cgroups";
    homepage = "https://github.com/libcgroup/libcgroup";
    license = lib.licenses.lgpl2;
    maintainers = [ lib.maintainers.thoughtpolice ];
    platforms = lib.platforms.linux;
  };
})
