{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  curl,
  dmenu,
  fzf,
  gnused,
  jq,
  makeWrapper,
  mpv,
  ueberzugpp,
  yt-dlp,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ytfzf";
  version = "2.6.2";

  src = fetchFromGitHub {
    owner = "pystardust";
    repo = "ytfzf";
    rev = "v${finalAttrs.version}";
    hash = "sha256-rwCVOdu9UfTArISt8ITQtLU4Gj2EZd07bcFKvxXQ7Bc=";
  };

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram "$out/bin/ytfzf" \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          curl
          dmenu
          fzf
          gnused
          jq
          mpv
          ueberzugpp
          yt-dlp
        ]
      } \
      --set YTFZF_SYSTEM_ADDON_DIR "$out/share/ytfzf/addons"
  '';

  dontBuild = true;

  installFlags = [
    "PREFIX="
    "DESTDIR=${placeholder "out"}"
    "doc"
    "addons"
  ];

  meta = {
    description = "Posix script to find and watch youtube videos from the terminal";
    homepage = "https://github.com/pystardust/ytfzf";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dotlambda ];
    platforms = lib.platforms.all;
    mainProgram = "ytfzf";
  };
})
