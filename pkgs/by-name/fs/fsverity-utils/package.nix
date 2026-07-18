{
  lib,
  stdenv,
  fetchzip,
  openssl,
  pandoc,
  enableManpages ? false,
  enableShared ? !stdenv.hostPlatform.isStatic,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fsverity-utils";
  version = "1.7";

  src = fetchzip {
    url = "https://git.kernel.org/pub/scm/fs/fsverity/fsverity-utils.git/snapshot/fsverity-utils-v${finalAttrs.version}.tar.gz";
    sha256 = "sha256-c8dillkgGh41elo/a5EqGQIrS4TZeDLsYkmyNke6koc=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
  ]
  ++ lib.optional enableManpages "man";

  patches = lib.optionals (!enableShared) [
    ./remove-dynamic-libs.patch
  ];

  strictDeps = true;
  nativeBuildInputs = lib.optional enableManpages pandoc;
  buildInputs = [ openssl ];

  makeFlags = [
    "DESTDIR=$(out)"
    "PREFIX="
  ]
  ++ lib.optional enableShared "USE_SHARED_LIB=1";

  doCheck = true;

  postInstall = ''
    mkdir -p $lib
    mv $out/lib $lib/lib
  '';

  enableParallelBuilding = true;
  installTargets = [ "install" ] ++ lib.optional enableManpages "install-man";

  meta = {
    description = "Set of userspace utilities for fs-verity";
    homepage = "https://www.kernel.org/doc/html/latest/filesystems/fsverity.html#userspace-utility";
    changelog = "https://git.kernel.org/pub/scm/fs/fsverity/fsverity-utils.git/tree/NEWS.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jk ];
    platforms = lib.platforms.linux;
    mainProgram = "fsverity";
  };
})
