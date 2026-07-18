{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  ethtool,
  gnugrep,
  gnused,
  ipcalc,
  iproute2,
  makeWrapper,
  nvme-cli,
  udevCheckHook,
  util-linux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "google-guest-configs";
  version = "20211116.00";

  src = fetchFromGitHub {
    owner = "GoogleCloudPlatform";
    repo = "guest-configs";
    rev = finalAttrs.version;
    sha256 = "sha256-0SRu6p/DsHNNI20mkXJitt/Ee5S2ooiy5hNmD+ndecM=";
  };

  postPatch = ''
    substitute ${./fix-paths.patch} fix-paths.patch \
      --subst-var out \
      --subst-var-by nvme "${nvme-cli}/bin/nvme" \
      --subst-var-by sh "${stdenv.shell}" \
      --subst-var-by umount "${util-linux}/bin/umount" \
      --subst-var-by logger "${util-linux}/bin/logger"
    patch -p1 < ./fix-paths.patch
  '';

  nativeBuildInputs = [
    makeWrapper
    udevCheckHook
  ];

  installPhase = ''
    mkdir -p $out/{bin,etc,lib}
    cp -r src/etc/{modprobe.d,sysctl.d} $out/etc
    cp -r src/lib/udev $out/lib
    cp -r src/sbin/* $out/bin
    cp -r src/usr/bin/* $out/bin

    for i in $out/bin/* $out/lib/udev/google_nvme_id; do
      wrapProgram "$i" \
        --prefix "PATH" ":" "$binDeps"
    done
  '';

  doInstallCheck = true;

  binDeps = lib.makeBinPath [
    coreutils
    util-linux
    gnugrep
    gnused
    ethtool
    ipcalc
    iproute2
  ];

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Linux Guest Environment for Google Compute Engine";
    homepage = "https://github.com/GoogleCloudPlatform/guest-configs";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
