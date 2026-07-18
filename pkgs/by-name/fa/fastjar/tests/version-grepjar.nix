{ fastjar, testers }:

testers.testVersion {
  command = "grepjar --version";
  package = fastjar;
}
