{
  lib,
  stdenv,
  fetchFromGitHub,
  fuse3,
  libpcap,
  nixosTests,
  pkg-config,
  python3,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "moosefs";
  version = "4.59.2";

  src = fetchFromGitHub {
    owner = "moosefs";
    repo = "moosefs";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-kWJI0lsVy4KmCIUbuIHswuN/lnMgG/eR6goya+keoy0=";
  };

  # Fix the build on macOS with macFUSE installed
  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace configure --replace \
      "/usr/local/lib/pkgconfig" "/nonexistent"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    python3
  ];

  buildInputs = [
    fuse3
    libpcap
    zlib
    python3
  ];

  buildFlags = lib.optionals stdenv.hostPlatform.isDarwin [
    "CPPFLAGS=-UHAVE_STRUCT_STAT_ST_BIRTHTIME"
  ];

  preBuild = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace config.h --replace \
      "#define HAVE_STRUCT_STAT_ST_BIRTHTIME 1" \
      "#undef HAVE_STRUCT_STAT_ST_BIRTHTIME"
  '';

  doCheck = true;

  passthru.tests = {
    inherit (nixosTests) moosefs;
  };

  meta = {
    description = "Open Source, Petabyte, Fault-Tolerant, Highly Performing, Scalable Network Distributed File System";
    homepage = "https://moosefs.com";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      mfossen
      markuskowa
    ];

    platforms = lib.platforms.unix;
  };
})
