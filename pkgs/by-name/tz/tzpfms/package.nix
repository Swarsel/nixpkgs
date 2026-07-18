{
  lib,
  stdenv,
  fetchFromSourcehut,
  libtirpc,
  libuuid,
  mandoc,
  nix-update-script,
  openssl,
  pkgconf,
  shellcheck,
  tpm2-tss,
  trousers,
  zfs,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tzpfms";
  version = "0.4.1";

  src = fetchFromSourcehut {
    owner = "~nabijaczleweli";
    repo = "tzpfms";
    rev = "v${finalAttrs.version}";
    hash = "sha256-DHmJpfURyFPeOWxIkfwn4f0n2WeDYErevC1gY2oM3Vg=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "-flto=full" "" \
      --replace-fail "-flto" "" \
      --replace-fail "out/" "$out/" \
      --replace-fail "ln -f" "ln -sf"
    substituteInPlace src/bin/zfs-tpm-list.cpp \
      --replace-fail "none     = -1," "none     = (char)-1,"
  '';

  nativeBuildInputs = [
    mandoc
    pkgconf
    shellcheck
  ];

  buildInputs = [
    libtirpc
    libuuid
    openssl
    tpm2-tss
    trousers
    zfs
    zlib
  ];

  env = {
    TZPFMS_DATE = "January 1, 1980";
    TZPFMS_VERSION = ''"${finalAttrs.version}"'';
  };

  preFixup = ''
    rm -rf $out/{build,systemd,initramfs-tools,dracut}
    mkdir -p $out/bin
    mv -v $out/zfs-* $out/bin
  '';

  dontInstall = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "TPM-based encryption keys for ZFS datasets.";

    longDescription = ''
      Essentially BitLocker, but for ZFS – a random raw key is generated
      and sealed to the TPM (both 2 and 1.x supported) with an additional
      optional password in front of it, tying the dataset to the platform
      and an additional optional secret (or to the possession of the back-up).
    '';

    homepage = "https://git.sr.ht/~nabijaczleweli/tzpfms";

    license = with lib.licenses; [
      mit
      bsd0
    ];

    maintainers = with lib.maintainers; [ numinit ];
    platforms = lib.platforms.linux;
  };
})
