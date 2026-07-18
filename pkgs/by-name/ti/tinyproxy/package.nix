{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fetchpatch2,
  nixosTests,
  perl,
  withDebug ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tinyproxy";
  version = "1.11.3";

  src = fetchFromGitHub {
    owner = "tinyproxy";
    repo = "tinyproxy";
    rev = finalAttrs.version;
    hash = "sha256-In/ZG50i2jKl0x7yfSs3KHlBdm8NdXtspMJPiv4BW6g=";
  };

  patches = [
    # Fix case-sensitive matching of "chunked" (CVE-2026-31842)
    (fetchpatch2 {
      hash = "sha256-Nav3nXyxdoM/tIvfyPJHEYEjAtrRrJlvkMXzsQCZan4=";
      name = "fix-chunked-case-sensitivity.patch";
      url = "https://github.com/tinyproxy/tinyproxy/commit/879bf844abffa0bf5fae6aff0c73179024dd9f98.patch";
    })
  ];

  # perl is needed for man page generation.
  nativeBuildInputs = [
    autoreconfHook
    perl
  ];

  configureFlags = lib.optionals withDebug [ "--enable-debug" ]; # Enable debugging support code and methods.
  passthru.tests = { inherit (nixosTests) tinyproxy; };

  meta = {
    description = "Light-weight HTTP/HTTPS proxy daemon for POSIX operating systems";
    homepage = "https://tinyproxy.github.io/";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.carlosdagos ];
    platforms = lib.platforms.all;
    mainProgram = "tinyproxy";
  };
})
