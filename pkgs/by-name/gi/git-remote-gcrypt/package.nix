{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  curl,
  docutils,
  gawk,
  gnugrep,
  gnupg,
  gnused,
  makeWrapper,
  rsync,
}:

stdenv.mkDerivation rec {
  pname = "git-remote-gcrypt";
  version = "1.5";

  src = fetchFromGitHub {
    inherit rev;
    owner = "spwhitton";
    repo = "git-remote-gcrypt";
    sha256 = "sha256-uy6s3YQwY/aZmQoW/qe1YrSlfNHyDTXBFxB6fPGiPNQ=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    docutils
    makeWrapper
  ];

  installPhase = ''
    prefix="$out" ./install.sh
    wrapProgram "$out/bin/git-remote-gcrypt" \
      --prefix PATH ":" "${
        lib.makeBinPath [
          gnupg
          curl
          rsync
          coreutils
          gawk
          gnused
          gnugrep
        ]
      }"
  '';

  rev = version;

  meta = {
    description = "Git remote helper for GPG-encrypted remotes";
    homepage = "https://spwhitton.name/tech/code/git-remote-gcrypt";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      ellis
      montag451
    ];

    platforms = lib.platforms.unix;
    mainProgram = "git-remote-gcrypt";
  };
}
