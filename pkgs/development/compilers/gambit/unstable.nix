{
  fetchFromGitHub,
  callPackage,
  gambit-support,
}:

callPackage ./build.nix rec {
  version = "unstable-2023-12-04";

  src = fetchFromGitHub {
    inherit rev;
    owner = "gambit";
    repo = "gambit";
    sha256 = "0njcz9krak8nfyk3x6bc6m1rixzsjc1fyzhbz2g3aq5v8kz9mkl5";
  };

  gambit-params = gambit-support.unstable-params;
  git-version = "4.9.5-84-g6b19d0c9";
  rev = "6b19d0c9084341306bbb7d6895321090a82988a0";
  stampHms = 204859;
  stampYmd = 20231204;
}
