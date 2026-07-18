{ fetchurl, callPackage, ... }@args:

callPackage ./generic.nix (
  args
  // rec {
    version = "1.90.0";

    src = fetchurl {
      # SHA256 from http://www.boost.org/users/history/version_1_90_0.html
      sha256 = "49551aff3b22cbc5c5a9ed3dbc92f0e23ea50a0f7325b0d198b705e8ee3fc305";

      urls = [
        "mirror://sourceforge/boost/boost_${builtins.replaceStrings [ "." ] [ "_" ] version}.tar.bz2"
        "https://boostorg.jfrog.io/artifactory/main/release/${version}/source/boost_${
          builtins.replaceStrings [ "." ] [ "_" ] version
        }.tar.bz2"
      ];
    };
  }
)
