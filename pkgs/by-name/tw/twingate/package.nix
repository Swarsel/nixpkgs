{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  cryptsetup,
  curl,
  dbus,
  dpkg,
  libnl,
  nixosTests,
  udev,
}:

stdenv.mkDerivation rec {
  pname = "twingate";
  version = "2026.160.6555";

  src = fetchurl {
    url = "https://binaries.twingate.com/client/linux/DEB/x86_64/${version}/twingate-amd64.deb";
    hash = "sha256-Sk2pALZtcraNpca6wkDiPCvWgU0hYlSeiwwszfZeKeM=";
  };

  postPatch = ''
    while read file; do
      substituteInPlace "$file" \
        --replace "/usr/bin" "$out/bin" \
        --replace "/usr/sbin" "$out/bin"
    done < <(find etc usr/lib usr/share -type f)
  '';

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = [
    dbus
    curl
    libnl
    udev
    cryptsetup
  ];

  installPhase = ''
    mkdir $out
    mv etc $out/
    mv usr/bin $out/bin
    mv usr/sbin/* $out/bin
    mv usr/lib $out/lib
    mv usr/share $out/share
  '';

  passthru.tests = { inherit (nixosTests) twingate; };

  meta = {
    description = "Twingate Client";
    homepage = "https://twingate.com";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
