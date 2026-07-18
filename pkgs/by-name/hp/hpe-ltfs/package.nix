{
  lib,
  stdenv,
  fetchFromGitHub,
  fuse,
  icu66,
  libuuid,
  libxml2,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hpe-ltfs";
  version = "3.4.2_Z7550-02501";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "hpe-ltfs";
    rev = finalAttrs.version;
    sha256 = "193593hsc8nf5dn1fkxhzs1z4fpjh64hdkc8q6n9fgplrpxdlr4s";
  };

  # include sys/sysctl.h is deprecated in glibc. The sysctl calls are only used
  # for Apple to determine the kernel version. Because this build only targets
  # Linux is it safe to remove.
  patches = [ ./remove-sysctl.patch ];
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    fuse
    icu66
    libxml2
    libuuid
  ];

  sourceRoot = "${finalAttrs.src.name}/ltfs";

  meta = {
    description = "HPE's implementation of the open-source tape filesystem standard ltfs";
    homepage = "https://support.hpe.com/hpesc/public/km/product/1009214665/Product";
    license = lib.licenses.lgpl21;
    maintainers = [ lib.maintainers.redvers ];
    platforms = lib.platforms.linux;
    downloadPage = "https://github.com/nix-community/hpe-ltfs";
  };
})
