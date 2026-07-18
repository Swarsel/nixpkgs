{ fetchurl, callPackage, ... }@args:

callPackage ./generic.nix (
  args
  // rec {
    version = "1.87.0";

    src = fetchurl {
      # SHA256 from http://www.boost.org/users/history/version_1_87_0.html
      sha256 = "af57be25cb4c4f4b413ed692fe378affb4352ea50fbe294a11ef548f4d527d89";

      urls = [
        "mirror://sourceforge/boost/boost_${builtins.replaceStrings [ "." ] [ "_" ] version}.tar.bz2"
        "https://boostorg.jfrog.io/artifactory/main/release/${version}/source/boost_${
          builtins.replaceStrings [ "." ] [ "_" ] version
        }.tar.bz2"
      ];
    };
  }
)
