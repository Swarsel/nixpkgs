{ Prelude, buildDhallGitHubPackage }:

let
  version = "0.9.64";

in
buildDhallGitHubPackage {
  dependencies = [ Prelude ];
  file = "package.dhall";
  name = "cloudformation";
  owner = "jcouyang";
  repo = "dhall-aws-cloudformation";
  rev = version;
  sha256 = "sha256-EDbMKHORYQOKoSrbErkUnsadDiYfK1ULbFhz3D5AcXc=";
}
