{
  lib,
  fetchFromGitHub,
  binlore,
  buildNpmPackage,
  jq,
  runCommand,
}:

buildNpmPackage (finalAttrs: {
  pname = "hred";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "danburzo";
    repo = "hred";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+0+WQRI8rdIMbPN0eBUdsWUMWDCxZhTRLiFo1WRd2xc=";
  };

  npmDepsHash = "sha256-kNNvSxZqN6cDZIG+lvqxgjAVCJUJrCvZThxrur5kozU=";
  dontNpmBuild = true;
  passthru.binlore.out = binlore.synthesize finalAttrs.finalPackage "execer cannot bin/hred";

  passthru.tests = {
    simple = runCommand "hred-test" { } ''
      set -e -o pipefail
      echo '<i id="foo">bar</i>' | ${finalAttrs.finalPackage}/bin/hred 'i#foo { @id => id, @.textContent => text }' -c | ${jq}/bin/jq -c > $out
      [ "$(cat $out)" = '{"id":"foo","text":"bar"}' ]
    '';
  };

  meta = {
    description = "Command-line tool to extract data from HTML";
    homepage = "https://github.com/danburzo/hred";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tejing ];
    mainProgram = "hred";
  };
})
