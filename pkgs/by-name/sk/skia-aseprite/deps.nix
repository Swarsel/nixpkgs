{ fetchgit }:
{
  angle2 = fetchgit {
    fetchSubmodules = false;
    hash = "sha256-Cz9n2ya4l3L1lvF4elHYJCfxr3l+h5UYOEhrhtw6WJg=";
    rev = "21d124c4bf321a18dae1dc94602aa262fc346a8b";
    url = "https://chromium.googlesource.com/angle/angle.git";
  };

  dng_sdk = fetchgit {
    hash = "sha256-lTtvBUGaia0jhrxpw7k7NIq2SVyGmBJPCvjIqAQCmNo=";
    rev = "c8d0c9b1d16bfda56f15165d39e0ffa360a11123";
    url = "https://android.googlesource.com/platform/external/dng_sdk.git";
  };

  icu = fetchgit {
    hash = "sha256-BI3f/gf9GNDvSfXWeRHKBvznSz4mjXY8rM24kK7QvOM=";
    rev = "a0718d4f121727e30b8d52c7a189ebf5ab52421f";
    url = "https://chromium.googlesource.com/chromium/deps/icu.git";
  };

  icu4x = fetchgit {
    hash = "sha256-Lha5m97zwTBFJZZUwewCv1blQh/VgDR0G2h+GMMAzME=";
    rev = "bcf4f7198d4dc5f3127e84a6ca657c88e7d07a13";
    url = "https://chromium.googlesource.com/external/github.com/unicode-org/icu4x.git";
  };

  piex = fetchgit {
    hash = "sha256-IhAfxlu0UmllihBP9wbg7idT8azlbb9arLKUaZ6qNxY=";
    rev = "bb217acdca1cc0c16b704669dd6f91a1b509c406";
    url = "https://android.googlesource.com/platform/external/piex.git";
  };

  wuffs = fetchgit {
    hash = "sha256-373d2F/STcgCHEq+PO+SCHrKVOo6uO1rqqwRN5eeBCw=";
    rev = "e3f919ccfe3ef542cfc983a82146070258fb57f8";
    url = "https://skia.googlesource.com/external/github.com/google/wuffs-mirror-release-c.git";
  };
}
