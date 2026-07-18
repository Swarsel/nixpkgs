{
  lib,
  stdenv,
  fetchFromGitHub,
  fzf,
  installShellFiles,
  libnotify,
  makeWrapper,
  mpc,
  perlPackages,
  rofi,
  tmux,
  unstableGitUpdater,
  util-linux,
}:

stdenv.mkDerivation {
  pname = "clerk";
  version = "0-unstable-2024-02-20";

  src = fetchFromGitHub {
    owner = "carnager";
    repo = "clerk";
    rev = "a3c4a0b88597e8194a5b29a20bc9eab1a12f4de9";
    hash = "sha256-UlACMlH4iYj1l/GIpBf6Pb7MuRHWlgxLPgAqzc+Zol8=";
  };

  postPatch = ''
    substituteInPlace clerk_rating_client.service \
      --replace "/usr" "$out"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  buildInputs = with perlPackages; [
    perl
    DataMessagePack
    DataSectionSimple
    ConfigSimple
    TryTiny
    IPCRun
    HTTPDate
    FileSlurper
    ArrayUtils
    NetMPD
  ];

  installPhase = ''
    runHook preInstall

    mv clerk.pl clerk
    installBin clerk clerk_rating_client
    install -D clerk_rating_client.service $out/lib/systemd/user/clerk_rating_client.service

    runHook postInstall
  '';

  postFixup =
    let
      binPath = lib.makeBinPath [
        fzf
        libnotify
        mpc
        rofi
        tmux
        util-linux
      ];
    in
    ''
      for f in clerk clerk_rating_client; do
        wrapProgram $out/bin/$f \
          --prefix PATH : "${binPath}" \
          --set PERL5LIB $PERL5LIB
      done
    '';

  dontBuild = true;

  passthru.updateScript = unstableGitUpdater {
    hardcodeZeroVersion = true;
    url = "https://github.com/carnager/clerk.git";
  };

  meta = {
    description = "MPD client based on rofi/fzf";
    homepage = "https://github.com/carnager/clerk";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      anderspapitto
      wineee
    ];

    platforms = lib.platforms.linux;
    mainProgram = "clerk";
  };
}
