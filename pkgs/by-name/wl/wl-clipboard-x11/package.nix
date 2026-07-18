{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  wl-clipboard,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wl-clipboard-x11";
  version = "5";

  src = fetchFromGitHub {
    owner = "brunelli";
    repo = "wl-clipboard-x11";
    rev = "v${finalAttrs.version}";
    hash = "sha256-i+oF1Mu72O5WPTWzqsvo4l2CERWWp4Jq/U0DffPZ8vg=";
  };

  postPatch = ''
    substituteInPlace src/wl-clipboard-x11 \
      --replace '$(command -v wl-copy)' ${wl-clipboard}/bin/wl-copy \
      --replace '$(command -v wl-paste)' ${wl-clipboard}/bin/wl-paste
  '';

  strictDeps = true;
  buildInputs = [ bash ];
  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = {
    description = "Wrapper to use wl-clipboard as a drop-in replacement for X11 clipboard tools";
    homepage = "https://github.com/brunelli/wl-clipboard-x11";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ artturin ];
    platforms = lib.platforms.linux;
    mainProgram = "xclip";
  };
})
