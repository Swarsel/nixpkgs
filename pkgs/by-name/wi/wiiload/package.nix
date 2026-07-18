{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "wiiload";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "devkitPro";
    repo = "wiiload";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-pZdZzCAPfAVucuiV/q/ROY3cz/wxQWep6dCTGNn2fSo=";
  };

  patches = [
    # https://github.com/devkitPro/wiiload/pull/4
    ./fix-gcc15.patch
  ];

  nativeBuildInputs = [
    autoconf
    automake
  ];

  buildInputs = [ zlib ];
  preConfigure = "./autogen.sh";

  meta = {
    description = "Load homebrew apps over network/usbgecko to your Wii";
    homepage = "https://wiibrew.org/wiki/Wiiload";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ tomsmeets ];
    mainProgram = "wiiload";
  };
})
