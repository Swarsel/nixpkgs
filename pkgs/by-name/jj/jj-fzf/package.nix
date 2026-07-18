{
  lib,
  stdenv,
  fetchFromGitHub,
  bashInteractive,
  coreutils,
  fzf,
  gawk,
  gnused,
  jujutsu,
  makeWrapper,
  pandoc,
  python3,
  unixtools,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jj-fzf";
  version = "0.38.0";

  src = fetchFromGitHub {
    owner = "tim-janik";
    repo = "jj-fzf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sWW8A+Y25jcYPEHEgqWjwaGm/eWqNCnDLgqK9WXq6HM=";
  };

  patches = [ ./nix-preflight.patch ];

  postPatch = ''
    substituteInPlace lib/gen-message.py \
      --replace-fail '/usr/bin/env -S python3 -B' '${python3}/bin/python -B'
    patchShebangs --build lib/*.sh
    patchShebangs --host jj-fzf *.sh contrib/*.sh
  '';

  strictDeps = true;

  nativeBuildInputs = [
    bashInteractive
    makeWrapper
    pandoc
    jujutsu
  ];

  buildInputs = [ bashInteractive ];
  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  postInstall = ''
    wrapProgram $out/bin/jj-fzf \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          fzf
          gawk
          gnused
          jujutsu
          python3
          unixtools.column
        ]
      }
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Text UI for Jujutsu based on fzf";
    homepage = "https://github.com/tim-janik/jj-fzf";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ bbigras ];
    platforms = lib.platforms.all;
    mainProgram = "jj-fzf";
  };
})
