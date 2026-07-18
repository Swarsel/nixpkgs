{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-source,
  pylint,
  python3,
  runtimeShell,
  which,
}:
stdenv.mkDerivation rec {
  pname = "gup";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "timbertson";
    repo = "gup";
    rev = "version-${version}";
    hash = "sha256-bV5HauM0xmRI/9Pxp1cYLPLA8PbFvPER2y4mAMmgchs=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    python3
    which
    pylint
  ];

  buildInputs = [ python3 ];
  buildPhase = "make python";

  installPhase = ''
    mkdir $out
    cp -r python/bin $out/bin
  '';

  passthru.updateScript = [
    runtimeShell
    "-c"
    ''
      set -e
      echo
      cd ${toString ./.}
      ${nix-update-source}/bin/nix-update-source \
        --prompt version \
        --replace-attr version \
        --set owner timbertson \
        --set repo gup \
        --set type fetchFromGitHub \
        --set rev 'version-{version}' \
        --nix-literal rev 'version-''${version}'\
        --modify-nix package.nix
    ''
  ];

  meta = {
    inherit (src.meta) homepage;
    description = "Better make, inspired by djb's redo";
    license = lib.licenses.lgpl2Plus;
    maintainers = [ lib.maintainers.timbertson ];
    platforms = lib.platforms.all;
  };
}
