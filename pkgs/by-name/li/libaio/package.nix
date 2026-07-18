{
  lib,
  stdenv,
  fetchFromCodeberg,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libaio";
  version = "0.3.113";

  src = fetchFromCodeberg {
    owner = "jmoyer";
    repo = "libaio";
    tag = "libaio-${finalAttrs.version}";
    hash = "sha256-8TofYbwsnenv5GuC6FjkUt9rBTULEb5nhknuxr2ckQg=";
  };

  postPatch = ''
    patchShebangs harness

    # Makefile is too optimistic, gcc is too smart
    substituteInPlace harness/Makefile \
      --replace "-Werror" ""
  '';

  makeFlags = [
    "prefix=${placeholder "out"}"
  ]
  ++ lib.optional stdenv.hostPlatform.isStatic "ENABLE_SHARED=0";

  checkTarget = "partcheck"; # "check" needs root
  hardeningDisable = lib.optional (stdenv.hostPlatform.isi686) "stackprotector";

  meta = {
    description = "Library for asynchronous I/O in Linux";
    homepage = "https://lse.sourceforge.net/io/aio.html";
    license = lib.licenses.lgpl21;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    downloadPage = "https://codeberg.org/jmoyer/libaio";
  };
})
