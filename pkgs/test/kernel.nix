# make sure to use NON EXISTING kernel settings else they may conflict with
# common-config.nix
{ lib, pkgs }:

let
  lts_kernel = pkgs.linuxPackages.kernel;

  # to see the result once the module transformed the lose structured config
  getConfig =
    structuredConfig:
    (lts_kernel.override {
      structuredExtraConfig = structuredConfig;
    }).configfile.structuredConfig;

  mandatoryVsOptionalConfig = lib.mkMerge [
    { NIXOS_FAKE_USB_DEBUG = lib.kernel.yes; }
    { NIXOS_FAKE_USB_DEBUG = lib.kernel.option lib.kernel.yes; }
  ];

  freeformConfig = lib.mkMerge [
    { NIXOS_FAKE_MMC_BLOCK_MINORS = lib.kernel.freeform "32"; } # same as default, won't trigger any error
    { NIXOS_FAKE_MMC_BLOCK_MINORS = lib.kernel.freeform "64"; } # will trigger an error but the message is not great:
  ];

  mkDefaultWorksConfig = lib.mkMerge [
    { "NIXOS_TEST_BOOLEAN" = lib.kernel.yes; }
    { "NIXOS_TEST_BOOLEAN" = lib.mkDefault lib.kernel.no; }
  ];

  allOptionalRemainOptional = lib.mkMerge [
    { NIXOS_FAKE_USB_DEBUG = lib.kernel.option lib.kernel.yes; }
    { NIXOS_FAKE_USB_DEBUG = lib.kernel.option lib.kernel.yes; }
  ];

  failures = lib.runTests {
    testAllOptionalRemainOptional = {
      expected = true;
      expr = (getConfig allOptionalRemainOptional)."NIXOS_FAKE_USB_DEBUG".optional;
    };

    testEasy = {
      expected = {
        freeform = null;
        optional = false;
        tristate = "y";
      };

      expr = (getConfig { NIXOS_FAKE_USB_DEBUG = lib.kernel.yes; }).NIXOS_FAKE_USB_DEBUG;
    };

    # mandatory flag should win over optional
    testMandatoryCheck = {
      expected = false;
      expr = (getConfig mandatoryVsOptionalConfig).NIXOS_FAKE_USB_DEBUG.optional;
    };

    # check that freeform options are unique
    # Should trigger
    # > The option `settings.NIXOS_FAKE_MMC_BLOCK_MINORS.freeform' has conflicting definitions, in `<unknown-file>' and `<unknown-file>'
    testTreeform =
      let
        res = builtins.tryEval ((getConfig freeformConfig).NIXOS_FAKE_MMC_BLOCK_MINORS.freeform);
      in
      {
        expected = false;
        expr = res.success;
      };

    testYesWinsOverNo = {
      expected = "y";
      expr = (getConfig mkDefaultWorksConfig)."NIXOS_TEST_BOOLEAN".tristate;
    };

  };
in

lib.debug.throwTestFailures {
  inherit failures;
  description = "kernel unit tests";
}
