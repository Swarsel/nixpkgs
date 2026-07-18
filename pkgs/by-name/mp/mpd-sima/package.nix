{
  lib,
  fetchFromGitLab,
  nix-update-script,
  python3Packages,
  sphinxHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "mpd-sima";
  version = "0.18.2";

  src = fetchFromGitLab {
    owner = "kaliko";
    repo = "sima";
    rev = finalAttrs.version;
    hash = "sha256-lMvM1EqS1govhv4B2hJzIg5DFQYgEr4yJJtgOQxnVlY=";
  };

  postPatch = ''
    sed -i '/intersphinx/d' doc/source/conf.py
  '';

  nativeBuildInputs = [
    sphinxHook
  ];

  doCheck = true;

  preCheck = ''
    export HOME="$(mktemp -d)"
  '';

  dependencies = with python3Packages; [
    requests
    python-musicpd
  ];

  format = "setuptools";
  sphinxBuilders = [ "man" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Autoqueuing mpd client";
    homepage = "https://kaliko.me/mpd-sima/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ apfelkuchen6 ];
    platforms = lib.platforms.linux;
    mainProgram = "mpd-sima";
  };
})
