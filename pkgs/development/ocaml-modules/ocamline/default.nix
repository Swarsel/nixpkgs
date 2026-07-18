{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  linenoise,
}:

buildDunePackage (finalAttrs: {
  pname = "ocamline";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "chrisnevers";
    repo = "ocamline";
    rev = finalAttrs.version;
    sha256 = "Sljm/Bfr2Eo0d75tmJRuWUkkfHUYQ0g27+FzXBePnVg=";
  };

  propagatedBuildInputs = [ linenoise ];

  meta = {
    description = "Command line interface for user input";
    homepage = "https://chrisnevers.github.io/ocamline/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ mgttlinger ];
  };
})
