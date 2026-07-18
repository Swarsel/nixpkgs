{
  lib,
  fetchFromGitHub,
  bash,
  gh,
  git,
  jq,
  makeWrapper,
  nix-update-script,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gh-signoff";
  version = "0.2.1"; # version is in the script

  src = fetchFromGitHub {
    owner = "basecamp";
    repo = "gh-signoff";
    rev = "24f274070c9dfbb3916347dbf6f9d38d4fb64eca"; # Repo didn't have a valid Git tag for specific version
    hash = "sha256-jqRbh4To6uHoohkNZrzgmGWOBp/Mahmjm5NwXjmshhM=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [ bash ];

  installPhase = ''
    runHook preInstall
    install -D -m755 "gh-signoff" "$out/bin/gh-signoff"
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram "$out/bin/gh-signoff" \
      --prefix PATH : "${lib.makeBinPath finalAttrs.runtimeDeps}"
  '';

  runtimeDeps = [
    gh
    git
    jq
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    inherit (gh.meta) platforms;
    description = "GitHub CLI extension for local CI to sign off on your own work";
    homepage = "https://github.com/basecamp/gh-signoff";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maikotan ];
    mainProgram = "gh-signoff";
  };
})
