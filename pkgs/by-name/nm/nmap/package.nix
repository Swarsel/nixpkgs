{
  lib,
  stdenv,
  fetchurl,
  liblinear,
  libpcap,
  libssh2,
  lua5_4,
  openssl,
  pcre2,
  pkg-config,
  versionCheckHook,
  zlib,
  withLua ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nmap";
  version = "7.99";

  src = fetchurl {
    url = "https://nmap.org/dist/nmap-${finalAttrs.version}.tar.bz2";
    hash = "sha256-31Ekkv/RCOU6J6BvJthjW76J4OVpRV3I/+8FjANdUbI=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    pcre2
    liblinear
    libssh2
    libpcap
    openssl
    zlib
  ];

  configureFlags = [
    (if withLua then "--with-liblua=${lua5_4}" else "--without-liblua")
    "--without-ndiff"
    "--without-zenmap"
  ];

  makeFlags = lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
    "AR=${stdenv.cc.bintools.targetPrefix}ar"
    "RANLIB=${stdenv.cc.bintools.targetPrefix}ranlib"
    "CC=${stdenv.cc.targetPrefix}gcc"
  ];

  doCheck = false; # fails 3 tests, probably needs the net

  postInstall = ''
    install -m 444 -D nselib/data/passwords.lst $out/share/wordlists/nmap.lst
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    install_name_tool -change liblinear.so.5 ${liblinear.out}/lib/liblinear.5.dylib $out/bin/nmap
  '';

  enableParallelBuilding = true;

  prePatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace libz/configure \
        --replace /usr/bin/libtool ar \
        --replace 'AR="libtool"' 'AR="ar"' \
        --replace 'ARFLAGS="-o"' 'ARFLAGS="-r"'
  '';

  versionCheckProgramArg = "-V";

  meta = {
    description = "Free and open source utility for network discovery and security auditing";
    homepage = "http://www.nmap.org";
    changelog = "https://nmap.org/changelog.html#${finalAttrs.version}";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      thoughtpolice
      fpletz
    ];

    platforms = lib.platforms.all;
  };
})
