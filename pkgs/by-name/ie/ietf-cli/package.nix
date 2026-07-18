{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3,
  rsync,
}:
python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "ietf-cli";
  version = "1.29";

  src = fetchFromGitHub {
    owner = "paulehoffman";
    repo = "ietf-cli";
    tag = finalAttrs.version;
    hash = "sha256-xpwUUyTq/8WOUjssNkXOvxBYPgL7pmVVPz6abKetVc8=";
  };

  buildInputs = [ rsync ];

  installPhase = ''
    runHook preInstall

    install -Dm755 ./ietf -t $out/bin

    runHook postInstall
  '';

  pyproject = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command-line interface for accessing IETF documents and other information";
    homepage = "https://github.com/paulehoffman/ietf-cli";
    license = lib.licenses.wtfpl;
    maintainers = with lib.maintainers; [ lilioid ];
    platforms = lib.lists.intersectLists python3.meta.platforms rsync.meta.platforms;
    mainProgram = "ietf";
  };
})
