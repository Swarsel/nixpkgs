{
  buildFHSEnv,
  callPackage,
  makeFontsConf,
  tiling_wm ? false,
}:

let
  mkStudio =
    opts:
    callPackage (import ./common.nix opts) {
      inherit buildFHSEnv;
      inherit tiling_wm;

      fontsConf = makeFontsConf {
        fontDirectories = [ ];
      };
    };
  stableVersion = {
    version = "2026.1.1.10"; # "Android Studio Quail 1 | 2026.1.1 Patch 2"
    sha256Hash = "sha256-+9PxFtEsrtck6o2g0s2ufnkRcPefKqESc+oPLSKiJNw=";
    url = "https://edgedl.me.gvt1.com/android/studio/ide-zips/2026.1.1.10/android-studio-quail1-patch2-linux.tar.gz";
  };
  betaVersion = {
    version = "2026.1.2.9"; # "Android Studio Quail 2 | 2026.1.2 RC 2"
    sha256Hash = "sha256-QzNhbE8Ryv0VGQY/VzhJhqeS0c6rrUpgXXVOoBV+NHE=";
    url = "https://edgedl.me.gvt1.com/android/studio/ide-zips/2026.1.2.9/android-studio-quail2-rc2-linux.tar.gz";
  };
  latestVersion = {
    version = "2026.1.3.3"; # "Android Studio Quail 3 | 2026.1.3 Canary 3"
    sha256Hash = "sha256-C8rbR+0iGNzsr7HtiNiFw++ZG9/t00/c1Ozr9ngssPs=";
    url = "https://edgedl.me.gvt1.com/android/studio/ide-zips/2026.1.3.3/android-studio-quail3-canary3-linux.tar.gz";
  };
in
{
  beta = mkStudio (
    betaVersion
    // {
      pname = "android-studio-beta";
      channel = "beta";
    }
  );

  canary = mkStudio (
    latestVersion
    // {
      pname = "android-studio-canary";
      channel = "canary";
    }
  );

  dev = mkStudio (
    latestVersion
    // {
      pname = "android-studio-dev";
      channel = "dev";
    }
  );

  # Attributes are named by their corresponding release channels
  stable = mkStudio (
    stableVersion
    // {
      pname = "android-studio";
      channel = "stable";
    }
  );
}
