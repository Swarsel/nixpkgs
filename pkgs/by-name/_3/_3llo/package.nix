{
  lib,
  bundlerApp,
}:

bundlerApp {
  pname = "3llo";
  exes = [ "3llo" ];
  gemdir = ./.;

  meta = {
    description = "Trello interactive CLI on terminal";
    homepage = "https://github.com/qcam/3llo";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
