{
  lib,
  stdenv,
  fetchFromGitHub,
  libx11,
  makeWrapper,
  xsetroot,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xscreenruler";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "julian-hoch";
    repo = "xscreenruler";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oRbZ8r9EOPcLuuX8VyCBNt6ljdnko/EV8C8aeR85xYU=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ libx11 ];
  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];

  installPhase = ''
    runHook preInstall
    install -Dm755 xscreenruler -t $out/bin
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/xscreenruler \
      --prefix PATH : ${lib.makeBinPath [ xsetroot ]}
  '';

  meta = {
    description = "Simple screen ruler using xlib";
    homepage = "https://github.com/julian-hoch/xscreenruler";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.julian-hoch ];
    platforms = lib.platforms.linux;
  };
})
