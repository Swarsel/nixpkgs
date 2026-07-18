{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  defaultVersion ? "0.17.0",
}:

{
  hash,
  pname,
  buildInputs ? [ ],
  doCheck ? true,
  minimalOCamlVersion ? "5.1",
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

    meta = {
      homepage = "https://github.com/janestreet/${pname}";
      license = lib.licenses.mit;
    }
    // args.meta;
  }
)
