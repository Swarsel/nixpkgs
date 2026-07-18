{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  libbacktrace,
  meson,
  ninja,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "libsegfault";
  version = "0-unstable-2022-11-13";

  src = fetchFromGitHub {
    owner = "jonathanpoelen";
    repo = "libsegfault";
    rev = "8bca5964613695bf829c96f7a3a14dbd8304fe1f";
    sha256 = "vKtY6ZEkyK2K+BzJCSo30f9MpERpPlUnarFIlvJ1Giw=";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  buildInputs = [
    boost
    libbacktrace
  ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString (stdenv.hostPlatform.isDarwin) "-DBOOST_STACKTRACE_GNU_SOURCE_NOT_REQUIRED=1";

  passthru = {
    updateScript = unstableGitUpdater { };
  };

  meta = {
    description = "Implementation of libSegFault.so with Boost.stracktrace";
    homepage = "https://github.com/jonathanpoelen/libsegfault";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jtojnar ];
    platforms = lib.platforms.unix;
  };
}
