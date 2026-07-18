{
  lib,
  fetchFromGitHub,
  bat,
  delta,
  fzf,
  gh,
  gnugrep,
  makeWrapper,
  python3,
  stdenvNoCC,
  withBat ? false,
  withDelta ? false,
}:
let
  binPath = lib.makeBinPath (
    [
      gh
      gnugrep
      fzf
      python3
    ]
    ++ lib.optional withBat bat
    ++ lib.optional withDelta delta
  );
in
stdenvNoCC.mkDerivation {
  pname = "gh-notify";
  version = "0-unstable-2024-08-01";

  src = fetchFromGitHub {
    owner = "meiji163";
    repo = "gh-notify";
    rev = "556df2eecdc0f838244a012759da0b76bcfeb2e7";
    hash = "sha256-WKv/1AW8wtl7kQ3PE7g2N0ELvdHtons7pYb0K8wsfWg=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    install -D -m755 "gh-notify" "$out/bin/gh-notify"
  '';

  postFixup = ''
    wrapProgram "$out/bin/gh-notify" --prefix PATH : "${binPath}"
  '';

  meta = {
    description = "GitHub CLI extension to display GitHub notifications";
    homepage = "https://github.com/meiji163/gh-notify";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ loicreynier ];
    platforms = lib.platforms.all;
    mainProgram = "gh-notify";
  };
}
