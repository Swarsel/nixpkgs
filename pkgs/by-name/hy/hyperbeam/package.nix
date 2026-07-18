{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "hyperbeam";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "holepunchto";
    repo = "hyperbeam";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SSHSQIVfHYFa1YkV3eeDkXSQV8KERADlmhOmxIiY+ko=";
  };

  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  npmDepsHash = "sha256-EjzdBqA1KNZbhkRkyMwC/YSgbkbs5BRC6ummQkQHyEs=";
  dontNpmBuild = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "1-1 End-to-End Encrypted Internet Pipe Powered by Hyperswarm";
    homepage = "https://github.com/holepunchto/hyperbeam";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ davhau ];
    platforms = lib.platforms.all;
    mainProgram = "hyperbeam";
    teams = with lib.teams; [ ngi ];
  };
})
