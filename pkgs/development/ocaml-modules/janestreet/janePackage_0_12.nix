{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  defaultVersion ? "0.12.0",
}:

{
  hash,
  pname,
  duneVersion ? "3",
  version ? defaultVersion,
  ...
}@args:

buildDunePackage (
  args
  // {
    inherit version duneVersion;

    src = fetchFromGitHub {
      owner = "janestreet";
      repo = pname;
      rev = "v${version}";
      sha256 = hash;
    };

    minimalOCamlVersion = "4.07";

    meta = {
      homepage = "https://github.com/janestreet/${pname}";
      license = lib.licenses.mit;
    }
    // args.meta;
  }
)
