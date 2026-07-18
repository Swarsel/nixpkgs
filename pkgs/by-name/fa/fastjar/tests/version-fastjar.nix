{ fastjar, testers }:

testers.testVersion {
  command = "fastjar --version";
  package = fastjar;
}
