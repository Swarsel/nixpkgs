{
  lib,
  stdenv,
  fetchurl,
  farbfeld,
  libx11,
  libxft,
  makeWrapper,
  patches ? [ ],
}:

stdenv.mkDerivation (finalAttrs: {
  inherit patches;
  pname = "sent";
  version = "1";

  src = fetchurl {
    url = "https://dl.suckless.org/tools/sent-${finalAttrs.version}.tar.gz";
    sha256 = "0cxysz5lp25mgww73jl0mgip68x7iyvialyzdbriyaff269xxwvv";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    libx11
    libxft
  ];

  postInstall = ''
    wrapProgram "$out/bin/sent" --prefix PATH : "${farbfeld}/bin"
  '';

  installFlags = [ "PREFIX=$(out)" ];
  # unpacking doesn't create a directory
  sourceRoot = ".";

  meta = {
    description = "Simple plaintext presentation tool";
    homepage = "https://tools.suckless.org/sent/";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.unix;
    mainProgram = "sent";
  };
})
