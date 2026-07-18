{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  autoreconfHook,
  doxygen,
  gettext,
  help2man,
  libxml2,
  perl,
  pkg-config,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libsmbios";
  version = "2.4.3";

  src = fetchFromGitHub {
    owner = "dell";
    repo = "libsmbios";
    rev = "v${finalAttrs.version}";
    sha256 = "0krwwydyvb9224r884y1mlmzyxhlfrcqw73vi1j8787rl0gl5a2i";
  };

  patches = [
    (fetchurl {
      name = "musl.patch";
      sha256 = "aVVc52OovDYvqWRyKcRAi62daa9AalkKvnVOGvrTmRk=";
      url = "https://git.alpinelinux.org/aports/plain/community/libsmbios/fixes.patch?id=bdc4f67889c958c1266fa5d0cab71c3cd639122f";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    doxygen
    gettext
    libxml2
    help2man
    perl
    pkg-config
  ];

  buildInputs = [ python3 ];
  configureFlags = [ "--disable-graphviz" ];

  postInstall = ''
    mkdir -p $out/include
    cp -a src/include/smbios_c $out/include/
    cp -a out/public-include/smbios_c $out/include/
  '';

  # remove forbidden reference to $TMPDIR
  preFixup = ''
    patchelf --shrink-rpath --allowed-rpath-prefixes "$NIX_STORE" "$out/sbin/smbios-sys-info-lite"
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Library to obtain BIOS information";
    homepage = "https://github.com/dell/libsmbios";

    license = with lib.licenses; [
      osl21
      gpl2Plus
    ];

    maintainers = [ ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
})
