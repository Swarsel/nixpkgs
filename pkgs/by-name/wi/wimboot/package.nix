{
  lib,
  stdenv,
  fetchFromGitHub,
  libbfd,
  libiberty,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wimboot";
  version = "2.9.0";

  src = fetchFromGitHub {
    owner = "ipxe";
    repo = "wimboot";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eS+Vcrwxws8p5j+U3Hg0G2psYYgPR1XP7QXyPelpxyg=";
  };

  buildInputs = [
    libbfd
    zlib
    libiberty
  ];

  makeFlags = [ "wimboot.x86_64.efi" ];

  installPhase = ''
    mkdir -p $out/share/wimboot/
    cp wimboot.x86_64.efi $out/share/wimboot
  '';

  sourceRoot = "${finalAttrs.src.name}/src";

  meta = {
    description = "Windows Imaging Format bootloader";
    homepage = "https://ipxe.org/wimboot";
    changelog = "https://github.com/ipxe/wimboot/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      das_j
      helsinki-Jo
    ];

    platforms = [ "x86_64-linux" ];
  };
})
