{
  lib,
  stdenv,
  acl,
  attr,
  autoreconfHook,
  fetchFromGitea,
  libiconv,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libisofs";
  version = "1.5.8.pl02";

  src = fetchFromGitea {
    owner = "libburnia";
    repo = "libisofs";
    rev = "release-${finalAttrs.version}";
    hash = "sha256-uyE+7H5zWcBgtOsoFtiLFroeqA0Kj7tg7s+1IzXNKBo=";
    domain = "dev.lovelyhq.com";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [
      acl
      attr
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      libiconv
    ]
    ++ [
      zlib
    ];

  enableParallelBuilding = true;

  meta = {
    description = "Library to create an ISO-9660 filesystem with extensions like RockRidge or Joliet";
    homepage = "https://dev.lovelyhq.com/libburnia/web/wiki";
    changelog = "https://dev.lovelyhq.com/libburnia/libisofs/src/tag/${finalAttrs.src.rev}/ChangeLog";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
