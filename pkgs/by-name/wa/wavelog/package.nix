{
  lib,
  fetchFromGitHub,
  nix-update-script,
  php,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "wavelog";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "wavelog";
    repo = "wavelog";
    tag = finalAttrs.version;
    hash = "sha256-RWARyBoRNHK9jd0T5u/QbL9w5TTzVeCcD4Elg/uWQNg=";
  };

  installPhase = ''
    runHook preInstall
    cp -R . $out
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Webbased Amateur Radio Logging Software";
    homepage = "https://www.wavelog.org";
    changelog = "https://github.com/wavelog/wavelog/releases/tag/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    platforms = php.meta.platforms;
    downloadPage = "https://github.com/wavelog/wavelog";
  };
})
