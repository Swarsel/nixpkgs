{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  defaultVersion ? "0.14.0",
}:

{
  hash,
  pname,
  buildInputs ? [ ],
  doCheck ? true,
  minimalOCamlVersion ? "4.08",
  version ? defaultVersion,
  ...
}@args:

buildDunePackage (
  args
  // {
    inherit version buildInputs;
    inherit minimalOCamlVersion;
    inherit doCheck;

    src = fetchFromGitHub {
      owner = "janestreet";
      repo = pname;
      rev = "v${version}";
      sha256 = hash;
    };

    duneVersion = "3";

    meta = {
      homepage = "https://github.com/janestreet/${pname}";
      license = lib.licenses.mit;
    }
    // args.meta;
  }
)
