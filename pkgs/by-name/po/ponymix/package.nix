{
  lib,
  stdenv,
  fetchFromGitHub,
  libnotify,
  libpulseaudio,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ponymix";
  version = "5";

  src = fetchFromGitHub {
    owner = "falconindy";
    repo = "ponymix";
    rev = finalAttrs.version;
    sha256 = "08yp7fprmzm6px5yx2rvzri0l60bra5h59l26pn0k071a37ks1rb";
  };

  postPatch = ''substituteInPlace Makefile --replace "\$(DESTDIR)/usr" "$out"'';
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libpulseaudio
    libnotify
  ];

  meta = {
    description = "CLI PulseAudio Volume Control";
    homepage = "https://github.com/falconindy/ponymix";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "ponymix";
  };
})
