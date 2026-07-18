{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "danger-gitlab";
  exes = [ "danger" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "danger-gitlab";

  meta = {
    description = "Gem that exists to ensure all dependencies are set up for Danger with GitLab";
    homepage = "https://github.com/danger/danger-gitlab-gem";
    license = lib.licenses.mit;
    mainProgram = "danger";
  };
}
