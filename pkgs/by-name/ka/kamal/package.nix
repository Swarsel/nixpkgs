{
  lib,
  bundlerApp,
  ruby,
}:

bundlerApp {
  inherit ruby;
  pname = "kamal";
  exes = [ "kamal" ];
  gemdir = ./.;

  meta = {
    description = "Deploy web apps anywhere";
    homepage = "https://kamal-deploy.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nathanruiz ];
    mainProgram = "kamal";
  };
}
