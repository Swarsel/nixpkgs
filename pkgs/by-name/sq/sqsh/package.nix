{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  freetds,
  libiconv,
  readline,
}:

let
  mainVersion = "2.5";

in
stdenv.mkDerivation (finalAttrs: {
  pname = "sqsh";
  version = "${mainVersion}.16.1";

  src = fetchurl {
    url = "mirror://sourceforge/sqsh/sqsh/sqsh-${mainVersion}/sqsh-${finalAttrs.version}.tgz";
    sha256 = "1wi0hdmhk7l8nrz4j3kaa177mmxyklmzhj7sq1gj4q6fb8v1yr6n";
  };

  patches = [
    (fetchurl {
      # https://cvsweb.openbsd.org/cgi-bin/cvsweb/ports/databases/sqsh/patches/patch-src_cmd_connect_c
      name = "patch-src_cmd_connect_c.patch";
      sha256 = "1dz97knr2h0a0ca1vq2mx6h8s3ns9jb1a0qraa4wkfmcdi3aqw0j";
      url = "https://cvsweb.openbsd.org/cgi-bin/cvsweb/~checkout~/ports/databases/sqsh/patches/patch-src_cmd_connect_c?rev=1.2&content-type=text/plain";
    })
  ];

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    freetds
    readline
    libiconv
  ];

  # 'bool' used as identifier rejected by gcc 15's C23 default.
  env.NIX_CFLAGS_COMPILE = "-std=gnu17";

  preConfigure = ''
    export SYBASE=${freetds}
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace configure --replace "libct.so" "libct.dylib"
  '';

  enableParallelBuilding = true;
  patchFlags = [ "-p0" ];

  meta = {
    description = "Command line tool for querying Sybase/MSSQL databases";

    longDescription = ''
      Sqsh (pronounced skwish) is short for SQshelL (pronounced s-q-shell),
      it is intended as a replacement for the venerable 'isql' program supplied
      by Sybase.
    '';

    homepage = "https://sourceforge.net/projects/sqsh/";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.all;
    mainProgram = "sqsh";
  };
})
