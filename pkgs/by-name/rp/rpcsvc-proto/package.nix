{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  buildPackages,
  fetchpatch,
  targetPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rpcsvc-proto";
  version = "1.4.4";

  src = fetchFromGitHub {
    owner = "thkukuk";
    repo = "rpcsvc-proto";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-DEXzSSmjMeMsr1PoU/ljaY+6b4COUU2Z8MJkGImsgzk=";
  };

  outputs = [
    "out"
    "man"
    "dev"
  ];

  patches = [
    # https://github.com/thkukuk/rpcsvc-proto/pull/14
    (fetchpatch {
      name = "follow-RPCGEN_CPP-env-var";
      sha256 = "sha256-KrUD6YwdyxW9S99h4TB21ahnAOgQmQr2tYz++MIbk1Y=";
      url = "https://github.com/thkukuk/rpcsvc-proto/commit/e772270774ff45172709e39f744cab875a816667.diff";
    })
  ];

  postPatch = ''
    # replace fallback cpp with the target prefixed cpp
    substituteInPlace rpcgen/rpc_main.c \
      --replace 'CPP = "cpp"' \
                'CPP = "${targetPackages.stdenv.cc.targetPrefix}cpp"'
  ''
  + lib.optionalString (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    substituteInPlace rpcsvc/Makefile.am \
      --replace '$(top_builddir)/rpcgen/rpcgen' '${buildPackages.rpcsvc-proto}/bin/rpcgen'
  '';

  nativeBuildInputs = [ autoreconfHook ];
  env.RPCGEN_CPP = "${stdenv.cc.targetPrefix}cpp";

  meta = {
    description = "This package contains rpcsvc proto.x files from glibc, which are missing in libtirpc";

    longDescription = ''
      The RPC-API has been removed from glibc. The 2.32-release-notes
      (https://sourceware.org/pipermail/libc-announce/2020/000029.html) recommend to use
      `libtirpc` and this package instead.
    '';

    homepage = "https://github.com/thkukuk/rpcsvc-proto";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ma27 ];
    mainProgram = "rpcgen";
  };
})
