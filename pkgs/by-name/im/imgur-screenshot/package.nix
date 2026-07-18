{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  gnugrep,
  jq,
  libnotify,
  makeWrapper,
  scrot,
  which,
  xclip,
}:

let
  deps = lib.makeBinPath [
    curl
    jq
    gnugrep
    libnotify
    scrot
    which
    xclip
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "imgur-screenshot";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "jomo";
    repo = "imgur-screenshot";
    rev = "v${finalAttrs.version}";
    sha256 = "0fkhvfraijbrw806pgij41bn1hc3r7l7l3snkicmshxj83lmsd5k";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dm755 imgur-screenshot $out/bin/imgur-screenshot
    wrapProgram $out/bin/imgur-screenshot --prefix PATH ':' ${deps}
  '';

  meta = {
    description = "Tool for easy screencapping and uploading to imgur";
    homepage = "https://github.com/jomo/imgur-screenshot/";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "imgur-screenshot";
  };
})
