{
  lib,
  stdenv,
  acl,
  attr,
  autoreconfHook,
  bzip2,
  fetchFromGitea,
  libburn,
  libcdio,
  libiconv,
  libisofs,
  pkg-config,
  readline,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libisoburn";
  version = "1.5.8.pl02";

  src = fetchFromGitea {
    owner = "libburnia";
    repo = "libisoburn";
    rev = "release-${finalAttrs.version}";
    hash = "sha256-wYX2foI0YXrhVENz8QqfS9IdXwbsHP7rqYOWzlo8FdM=";
    domain = "dev.lovelyhq.com";
  };

  outputs = [
    "out"
    "lib"
    "dev"
    "info"
    "man"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    bzip2
    libcdio
    libiconv
    readline
    zlib
    libburn
    libisofs
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    acl
    attr
  ];

  propagatedBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    acl
  ];

  meta = {
    inherit (libisofs.meta) platforms;
    description = "Enables creation and expansion of ISO-9660 filesystems on CD/DVD/BD";
    homepage = "http://libburnia-project.org/";
    changelog = "https://dev.lovelyhq.com/libburnia/libisoburn/src/tag/${finalAttrs.src.rev}/ChangeLog";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    mainProgram = "osirrox";
  };
})
