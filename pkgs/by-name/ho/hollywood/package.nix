{
  lib,
  stdenv,
  fetchFromGitHub,
  apg,
  atop,
  bmon,
  ccze,
  cmatrix,
  coreutils,
  findutils,
  jp2a,
  makeWrapper,
  man,
  mlocate,
  moreutils,
  mplayer,
  ncurses,
  openssh,
  python3Packages,
  tmux,
  tree,
  util-linux,
}:

stdenv.mkDerivation {
  pname = "hollywood";
  version = "1.22";

  src = fetchFromGitHub {
    owner = "dustinkirkland";
    repo = "hollywood";
    rev = "35275a68c37bbc39d8b2b0e4664a0c2f5451e5f6";
    sha256 = "sha256-faIm1uXERvIDZ6SK6uarVkWGNJskAroHgq5Cg7nUZc4=";
  };

  patches = [ ./nixos-paths.patch ];

  postPatch = ''
    rm lib/hollywood/speedometer
    rm bin/wallstreet
    rm -r lib/wallstreet
  '';

  nativeBuildInputs = [ makeWrapper ];

  installPhase =
    let
      pathDeps = [
        tmux
        coreutils
        ncurses
        jp2a
        mlocate
        apg
        atop
        bmon
        cmatrix
        python3Packages.pygments
        moreutils
        util-linux
        man
        mplayer
        openssh
        tree
        findutils
        ccze
      ];
    in
    ''
      runHook preInstall

      mkdir -p $out
      cp -r bin $out/bin
      cp -r lib $out/lib
      cp -r share $out/share
      wrapProgram $out/bin/hollywood --prefix PATH : ${lib.makeBinPath pathDeps}

      runHook postInstall
    '';

  dontBuild = true;

  meta = {
    description = "Fill your console with Hollywood melodrama technobabble";
    homepage = "https://a.hollywood.computer/";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "hollywood";
  };
}
