{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  ffcast,
  ffmpeg,
  gnused,
  libnotify,
  makeWrapper,
  procps,
  rofi,
  slop,
  xclip,
}:

stdenv.mkDerivation {
  pname = "rofi-screenshot";
  version = "2024-09-27";

  src = fetchFromGitHub {
    owner = "ceuk";
    repo = "rofi-screenshot";
    rev = "09a07d9c2ff2efbf75b1753bb412f4f8f086708f";
    hash = "sha256-3UpYdXAX3LD1ZAQ429JkzWWooiBpuf/uPf0CRh5EXd8=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dm755 rofi-screenshot $out/bin/rofi-screenshot
  '';

  postFixup = ''
    wrapProgram $out/bin/rofi-screenshot \
      --set PATH ${
        lib.makeBinPath [
          libnotify
          slop
          ffcast
          ffmpeg
          xclip
          rofi
          coreutils
          gnused
          procps
        ]
      }
  '';

  meta = {
    description = "Use rofi to perform various types of screenshots and screen captures";
    homepage = "https://github.com/ceuk/rofi-screenshot";
    license = lib.licenses.wtfpl;
    maintainers = with lib.maintainers; [ zopieux ];
    platforms = lib.platforms.all;
    mainProgram = "rofi-screenshot";
  };
}
