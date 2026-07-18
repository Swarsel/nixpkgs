{
  lib,
  stdenv,
  fetchurl,
  autoconf,
}:

stdenv.mkDerivation rec {
  pname = "dd_rescue";
  version = "1.99.21";

  src = fetchurl {
    url = "http://www.garloff.de/kurt/linux/ddrescue/dd_rescue-${version}.tar.bz2";
    hash = "sha256-YB3gyUX/8dsFfIbGUWX5rvRuIa2q9E4LOCtEOz+z/bk=";
  };

  buildInputs = [ autoconf ];
  makeFlags = [ "LIBDIR=$out" ];

  preBuild = ''
    substituteInPlace Makefile \
      --replace "\$(DESTDIR)/usr" "$out" \
      --replace "-o root" "" \
      --replace "-g root" ""
  '';

  postInstall = ''
    mkdir -p "$out/share/dd_rescue" "$out/bin"
    tar xf "${dd_rhelp_src}" -C "$out/share/dd_rescue"
    cp "$out/share/dd_rescue"/dd_rhelp*/dd_rhelp "$out/bin"
  '';

  dd_rhelp_src = fetchurl {
    sha256 = "0br6fs23ybmic3i5s1w4k4l8c2ph85ax94gfp2lzjpxbvl73cz1g";
    url = "http://www.kalysto.org/pkg/dd_rhelp-0.3.0.tar.gz";
  };

  meta = {
    description = "Tool to copy data from a damaged block device";
    homepage = "http://www.garloff.de/kurt/linux/ddrescue/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      raskin
    ];

    platforms = lib.platforms.linux;
    mainProgram = "dd_rescue";
  };
}
