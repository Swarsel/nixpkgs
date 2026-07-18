{
  lib,
  stdenv,
  fetchurl,
  getconf,
  openssl,
  util-linux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "scrypt";
  version = "1.3.3";

  src = fetchurl {
    url = "https://www.tarsnap.com/scrypt/scrypt-${finalAttrs.version}.tgz";
    sha256 = "sha256-HCcQUX6ZjqrC6X2xHwkuNxOeaYhrIaGyZh9k4TAhWuk=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
  ];

  nativeBuildInputs = [ getconf ];
  buildInputs = [ openssl ];
  configureFlags = [ "--enable-libscrypt-kdf" ];
  doCheck = true;
  nativeCheckInputs = lib.optionals stdenv.hostPlatform.isLinux [ util-linux ];
  checkTarget = "test";

  patchPhase = ''
    for f in Makefile.in autotools/Makefile.am libcperciva/cpusupport/Build/cpusupport.sh configure ; do
      substituteInPlace $f --replace "command -p " ""
    done

    patchShebangs tests/test_scrypt.sh
  '';

  meta = {
    description = "Encryption utility";
    homepage = "https://www.tarsnap.com/scrypt.html";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ thoughtpolice ];
    platforms = lib.platforms.all;
    mainProgram = "scrypt";
  };
})
