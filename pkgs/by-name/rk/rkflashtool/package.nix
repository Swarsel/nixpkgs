{
  lib,
  stdenv,
  fetchurl,
  libusb1,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rkflashtool";
  version = "6.1";

  src = fetchurl {
    url = "mirror://sourceforge/rkflashtool/rkflashtool-${finalAttrs.version}-src.tar.bz2";
    hash = "sha256-K8DsWAyqeQsK7mNDiKkRCkKbr0uT/yxPzj2atYP1Ezk=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libusb1 ];

  installPhase = ''
    mkdir -p $out/bin
    cp rkunpack rkcrc rkflashtool rkparameters rkparametersblock rkunsign rkmisc $out/bin
  '';

  meta = {
    description = "Tools for flashing Rockchip devices";
    homepage = "https://sourceforge.net/projects/rkflashtool/";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
