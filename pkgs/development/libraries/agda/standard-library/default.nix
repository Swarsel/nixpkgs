{
  lib,
  fetchFromGitHub,
  mkDerivation,
  nixosTests,
}:

mkDerivation rec {
  pname = "standard-library";
  version = "2.3";

  src = fetchFromGitHub {
    owner = "agda";
    repo = "agda-stdlib";
    rev = "v${version}";
    hash = "sha256-JOeoek6OfyIk9vwTj5QUJU6LnRzwfiG0e0ysW6zbhZ8=";
  };

  passthru.tests = { inherit (nixosTests) agda; };

  meta = {
    description = "Standard library for use with the Agda compiler";
    homepage = "https://wiki.portal.chalmers.se/agda/pmwiki.php?n=Libraries.StandardLibrary";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jwiegley
      mudri
      alexarice
      turion
    ];

    platforms = lib.platforms.unix;
  };
}
