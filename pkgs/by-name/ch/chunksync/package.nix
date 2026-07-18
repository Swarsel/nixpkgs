{
  lib,
  stdenv,
  fetchurl,
  openssl,
  perl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chunksync";
  version = "0.4";

  src = fetchurl {
    url = "https://chunksync.florz.de/chunksync_${finalAttrs.version}.tar.gz";
    sha256 = "1gwqp1kjwhcmwhynilakhzpzgc0c6kk8c9vkpi30gwwrwpz3cf00";
  };

  buildInputs = [
    openssl
    perl
  ];

  makeFlags = [
    "DESTDIR=$(out)"
    "PREFIX="
  ];

  env.NIX_LDFLAGS = "-lgcc_s";

  preInstall = ''
    mkdir -p $out/bin
    mkdir -p $out/share/man/man1
  '';

  meta = {
    description = "Space-efficient incremental backups of large files or block devices";
    homepage = "http://chunksync.florz.de/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ yayayayaka ];
    platforms = with lib.platforms; linux;
    mainProgram = "chunksync";
  };
})
