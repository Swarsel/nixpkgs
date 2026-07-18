{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  curl,
  fuse3,
  libxml2,
  openssl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "s3fs-fuse";
  version = "1.97";

  src = fetchFromGitHub {
    owner = "s3fs-fuse";
    repo = "s3fs-fuse";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iggSIrmxnhINdzJm60yTWkmDwUWJRNNVqwHGd2Lb7lw=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    curl
    openssl
    libxml2
    fuse3
  ];

  configureFlags = [
    "--with-openssl"
  ];

  postInstall = ''
    ln -s $out/bin/s3fs $out/bin/mount.s3fs
  '';

  meta = {
    description = "Mount an S3 bucket as filesystem through FUSE";
    homepage = "https://github.com/s3fs-fuse/s3fs-fuse";
    changelog = "https://github.com/s3fs-fuse/s3fs-fuse/raw/v${finalAttrs.version}/ChangeLog";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
