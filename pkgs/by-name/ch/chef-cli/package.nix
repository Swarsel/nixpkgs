{
  lib,
  bundlerApp,
  bundlerUpdateScript,
  ruby,
}:

bundlerApp {
  inherit ruby;
  pname = "chef-cli";
  exes = [ "chef-cli" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "chef-cli";

  meta = {
    description = "Chef Infra Client is a powerful agent that applies your configurations on remote Linux, macOS, Windows and cloud-based systems";
    homepage = "https://chef.io/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dylanmtaylor ];
    mainProgram = "chef-cli";
  };
}
