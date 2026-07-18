{
  lib,
  stdenv,
  buildMozillaMach,
  callPackage,
  nixosTests,
}:

let
  librewolf-src = callPackage ./librewolf.nix { };
in
(buildMozillaMach {
  inherit (librewolf-src)
    extraConfigureFlags
    extraPatches
    extraPostPatch
    extraPassthru
    ;

  pname = "librewolf";
  version = librewolf-src.packageVersion;
  src = librewolf-src.firefox;
  allowAddonSideload = true;
  applicationName = "LibreWolf";
  binaryName = "librewolf";
  branding = "browser/branding/librewolf";
  requireSigning = false;
  tests = { inherit (nixosTests) librewolf; };

  updateScript = callPackage ./update.nix {
    attrPath = "librewolf-unwrapped";
  };

  meta = {
    description = "Fork of Firefox, focused on privacy, security and freedom";
    homepage = "https://librewolf.net/";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      azahi
      dwrege
      fpletz
      hythera
      mBornand
      thbemme
      wolfgangwalther
    ];

    platforms = lib.platforms.unix;
    mainProgram = "librewolf";
    broken = stdenv.buildPlatform.is32bit;
    # since Firefox 60, build on 32-bit platforms fails with "out of memory".
    # not in `badPlatforms` because cross-compilation on 64-bit machine might work.
    maxSilent = 14400; # 4h, double the default of 7200s (c.f. #129212, #129115)
  };
}).override
  {
    crashreporterSupport = false;
    # This will set `MOZILLA_OFFICIAL=1`, which is set by the mozconfig upstream, but has to
    # be set manually in our case.
    # This will not override the branding as `branding` is already set to the official
    # Librewolf branding.
    enableOfficialBranding = true;
  }
