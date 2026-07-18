{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  fetchpatch,
  freetype,
  libxaw,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "libotf";
  version = "0.9.16";

  src = fetchurl {
    url = "mirror://savannah/m17n/${pname}-${version}.tar.gz";
    sha256 = "0sq6g3xaxw388akws6qrllp3kp2sxgk2dv4j79k6mm52rnihrnv8";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # https://salsa.debian.org/debian/libotf/-/tree/master/debian/patches
    # Fix cross-compilation
    (fetchpatch {
      sha256 = "sha256-VV9iGoNWIEie6UiLLTJBD+zxpvj0acgqkcBeAN1V6Kc=";
      url = "https://salsa.debian.org/debian/libotf/-/raw/1be04cedf887720eb8f5efb3594dc2cefd96b1f1/debian/patches/0002-use-pkg-config-not-freetype-config.patch";
    })
    # these 2 are required by the above patch
    (fetchpatch {
      sha256 = "sha256-3kzqNPAHNVJQ1F4fyifq3AqLdChWli/k7wOq+ha+iDs=";
      url = "https://salsa.debian.org/debian/libotf/-/raw/1be04cedf887720eb8f5efb3594dc2cefd96b1f1/debian/patches/0001-do-not-add-flags-for-required-packages-to-pc-file.patch";
    })
    (fetchpatch {
      sha256 = "sha256-SUlI87h+MtYWWtrAegzAnSds8JhxZwTJltDcj/se/Qc=";
      url = "https://salsa.debian.org/debian/libotf/-/raw/1be04cedf887720eb8f5efb3594dc2cefd96b1f1/debian/patches/0001-libotf-config-modify-to-support-multi-arch.patch";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [
    libxaw
    freetype
  ];

  postInstall = ''
    mkdir -p $dev/bin
    mv $out/bin/libotf-config $dev/bin/
    substituteInPlace $dev/bin/libotf-config \
      --replace "pkg-config" "${pkg-config}/bin/pkg-config"
  '';

  meta = {
    description = "Multilingual text processing library (libotf)";
    homepage = "https://www.nongnu.org/m17n/";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ bendlas ];
    platforms = lib.platforms.linux;
  };
}
