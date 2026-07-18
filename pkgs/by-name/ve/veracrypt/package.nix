{
  lib,
  stdenv,
  fetchFromGitHub,
  btrfs-progs,
  e2fsprogs,
  exfat,
  fuse3,
  lvm2,
  makeself,
  ntfs3g,
  pcsclite,
  pkg-config,
  replaceVars,
  wrapGAppsHook3,
  wxwidgets_3_2,
  yasm,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "veracrypt";
  version = "1.26.29";

  src = fetchFromGitHub {
    owner = "veracrypt";
    repo = "VeraCrypt";
    tag = "VeraCrypt_${finalAttrs.version}";
    hash = "sha256-Q+WUz8F63cP9/KlZUn9xLu2V9wO4FeY7AtErE1T9Km4=";
  };

  patches = [
    (replaceVars ./fix-paths.patch {
      btrfs = "${btrfs-progs}/bin/mkfs.btrfs";
      exfat = "${exfat}/bin/mkfs.exfat";
      ext2 = "${e2fsprogs}/bin/mkfs.ext2";
      ext3 = "${e2fsprogs}/bin/mkfs.ext3";
      ext4 = "${e2fsprogs}/bin/mkfs.ext4";
      ntfs = "${ntfs3g}/bin/mkfs.ntfs";
    })

    # https://github.com/veracrypt/VeraCrypt/commit/2cca2e1dafa405addc3af8724baf8563f352ac1c
    ./nix-system-paths.patch
  ];

  nativeBuildInputs = [
    makeself
    pkg-config
    yasm
    wrapGAppsHook3
  ];

  buildInputs = [
    fuse3
    lvm2
    wxwidgets_3_2
    pcsclite
  ];

  buildFlags = [ "WITHFUSE3=1" ];

  installPhase = ''
    install -Dm 755 Main/veracrypt "$out/bin/veracrypt"
    install -Dm 444 Resources/Icons/VeraCrypt-256x256.xpm "$out/share/pixmaps/veracrypt.xpm"
    install -Dm 444 License.txt -t "$out/share/doc/veracrypt/"
    install -d $out/share/applications
    substitute Setup/Linux/veracrypt.desktop $out/share/applications/veracrypt.desktop \
      --replace-fail "Exec=/usr/bin/veracrypt" "Exec=$out/bin/veracrypt" \
      --replace-fail "Icon=veracrypt" "Icon=veracrypt.xpm"
  '';

  enableParallelBuilding = true;
  sourceRoot = "${finalAttrs.src.name}/src";

  meta = {
    description = "Free Open-Source filesystem on-the-fly encryption";
    homepage = "https://www.veracrypt.fr/";

    license =
      with lib.licenses;
      AND [
        asl20 # and
        unfree # TrueCrypt License version 3.0
      ];

    maintainers = [ lib.maintainers.ryand56 ];
    platforms = lib.platforms.linux;
  };
})
