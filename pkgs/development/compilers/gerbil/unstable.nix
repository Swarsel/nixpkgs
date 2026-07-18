{
  fetchFromGitHub,
  callPackage,
  gambit-support,
}:

callPackage ./build.nix rec {
  inherit gambit-support;
  version = "unstable-2023-12-06";

  src = fetchFromGitHub {
    owner = "mighty-gerbils";
    repo = "gerbil";
    rev = "23c30a6062cd7e63f9d85300ce01585bb9035d2d";
    sha256 = "15fh0zqkmnjhan1mgymq5fgbjsh5z9d2v6zjddplqib5zd2s3z6k";
    fetchSubmodules = true;
  };

  # These are available in pkgs.gambit-unstable.passthru.git-version, etc.
  gambit-git-version = "4.9.5-78-g8b18ab69";
  gambit-params = gambit-support.unstable-params;
  gambit-stampHms = "163035";
  gambit-stampYmd = "20231029";
  git-version = "0.18.1";
}
