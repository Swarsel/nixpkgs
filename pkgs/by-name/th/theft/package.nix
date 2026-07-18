{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "theft";
  version = "0.4.5";

  src = fetchFromGitHub {
    owner = "silentbicycle";
    repo = "theft";
    rev = "v${finalAttrs.version}";
    sha256 = "1n2mkawfl2bpd4pwy3mdzxwlqjjvb5bdrr2x2gldlyqdwbk7qjhd";
  };

  patches = [ ./disable-failing-test.patch ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace "ar -rcs" "${stdenv.cc.targetPrefix}ar -rcs"
  '';

  preConfigure = "patchShebangs ./scripts/mk_bits_lut";
  doCheck = true;

  # fix the libtheft.pc file to use the right installation
  # directory. should be fixed upstream, too
  postInstall = ''
    install -m644 vendor/greatest.h $out/include/

    substituteInPlace $out/lib/pkgconfig/libtheft.pc \
      --replace "/usr/local" "$out"
  '';

  checkTarget = "test";
  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "C library for property-based testing";
    homepage = "https://github.com/silentbicycle/theft/";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      kquick
      thoughtpolice
    ];

    platforms = lib.platforms.unix;
  };
})
