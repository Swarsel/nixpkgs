{
  lib,
  stdenv,
  fetchurl,
  buildMozillaMach,
  callPackage,
  nixosTests,
}:

buildMozillaMach rec {
  pname = "firefox-devedition";
  version = "153.0b11";

  src = fetchurl {
    url = "mirror://mozilla/devedition/releases/${version}/source/firefox-${version}.source.tar.xz";
    sha512 = "b9cba9de51157db94ae421fcb82e2172e3a3b5026b01b1049c858e45302603dde9e8d859a163d1ec00e225788516fb769c1b7b1a4bd4f4ed3785c9552aab4e78";
  };

  applicationName = "Firefox Developer Edition";
  binaryName = "firefox-devedition";
  branding = "browser/branding/aurora";

  # buildMozillaMach sets MOZ_APP_REMOTINGNAME during configuration, but
  # unfortunately if the branding file also defines MOZ_APP_REMOTINGNAME, the
  # branding file takes precedence. ("aurora" is the only branding to do this,
  # so far.) We remove it so that the name set in buildMozillaMach takes
  # effect.
  extraPostPatch = ''
    sed -i '/^MOZ_APP_REMOTINGNAME=/d' browser/branding/aurora/configure.sh
  '';

  requireSigning = false;

  tests = {
    inherit (nixosTests) firefox-devedition;
  };

  updateScript = callPackage ../update.nix {
    attrPath = "firefox-devedition-unwrapped";
    baseUrl = "https://archive.mozilla.org/pub/devedition/releases/";
    versionSuffix = "b[0-9]*";
  };

  meta = {
    description = "Web browser built from Firefox Developer Edition source tree";
    homepage = "http://www.mozilla.com/en-US/firefox/";
    changelog = "https://www.mozilla.org/en-US/firefox/${lib.versions.majorMinor version}beta/releasenotes/";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      jopejoe1
      rhendric
    ];

    platforms = lib.platforms.unix;
    mainProgram = binaryName;
    broken = stdenv.buildPlatform.is32bit;
    # since Firefox 60, build on 32-bit platforms fails with "out of memory".
    # not in `badPlatforms` because cross-compilation on 64-bit machine might work.
    maxSilent = 14400; # 4h, double the default of 7200s (c.f. #129212, #129115)
  };
}
