{
  lib,
  stdenv,
  fetchFromGitHub,
  libbsd,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "signify";
  version = "32";

  src = fetchFromGitHub {
    owner = "aperezdc";
    repo = "signify";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-y2A+Szt451CmaWOc2Y2vBSwSgziJsSnTjNClbdyxG2U=";
  };

  postPatch = ''
    substituteInPlace Makefile --replace "shell pkg-config" "shell $PKG_CONFIG"
  '';

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libbsd ];
  doCheck = true;
  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "OpenBSD signing tool";

    longDescription = ''
      OpenBSDs signing tool, which uses the Ed25519 public key signature system
      for fast signing and verification of messages using small public keys.
    '';

    homepage = "https://www.tedunangst.com/flak/post/signify";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.rlupton20 ];
    platforms = lib.platforms.linux;
    mainProgram = "signify";
  };
})
