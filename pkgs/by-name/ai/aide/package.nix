{
  lib,
  stdenv,
  fetchurl,
  acl,
  attr,
  bison,
  flex,
  libgcrypt,
  libmhash,
  libselinux,
  pcre2,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "aide";
  version = "0.19.3";

  src = fetchurl {
    # We specifically want the tar.gz, so fetchFromGitHub is not suitable here
    url = "https://github.com/aide/aide/releases/download/v${finalAttrs.version}/${finalAttrs.pname}-${finalAttrs.version}.tar.gz";
    hash = "sha256-ZRMXC7W4wigC3Rty8C2KqfQyrvK0RwUi2wPnVSEqP0c=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    flex
    bison
    libmhash
    zlib
    acl
    attr
    libselinux
    pcre2
    libgcrypt
  ];

  configureFlags = [
    "--with-posix-acl"
    "--with-selinux"
    "--with-xattr"
    "--sysconfdir=/etc"
  ];

  meta = {
    description = "File and directory integrity checker";
    homepage = "https://aide.github.io/";
    changelog = "https://github.com/aide/aide/blob/v${finalAttrs.version}/ChangeLog";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ happysalada ];
    platforms = lib.platforms.linux;
    mainProgram = "aide";
  };
})
