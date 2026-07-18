{ testers, zchunk }:

testers.testVersion {
  command = "zck --version";
  package = zchunk;
}
