# Generic builder for tcl packages/applications
{
  lib,
  makeWrapper,
  tcl,
}:

let
  inherit (tcl) stdenv;
  inherit (lib) getBin optionalAttrs;

  defaultTclPkgConfigureFlags = [
    "--with-tcl=${tcl}/lib"
    "--with-tclinclude=${tcl}/include"
    "--exec-prefix=${placeholder "out"}"
    # Enable stubs by default for compatibility across minor versions
    "--enable-stubs"
  ];

in
lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;

  excludeDrvArgNames = [
    "addTclConfigureFlags"
    "checkPhase"
    "checkInputs"
    "nativeCheckInputs"
    "doCheck"
  ];

  extendDrvArgs =
    finalAttrs:
    args@{
      # Whether or not we should add common Tcl-related configure flags
      addTclConfigureFlags ? true,
      # Extra flags passed to configure step
      configureFlags ? [ ],
      # true if we should skip the configuration phase altogether
      dontConfigure ? false,
      ...
    }:
    (
      {
        nativeBuildInputs =
          args.nativeBuildInputs or [ ]
          ++ [
            makeWrapper
            tcl
          ]
          ++ lib.optionals (stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
            tcl.tclRequiresCheckHook
          ];

        buildInputs = args.buildInputs or [ ] ++ [ tcl.tclPackageHook ];
        propagatedBuildInputs = args.propagatedBuildInputs or [ ] ++ [ tcl ];

        # Add typical values expected by TEA for configureFlags
        configureFlags =
          if (!dontConfigure && addTclConfigureFlags) then
            (configureFlags ++ defaultTclPkgConfigureFlags)
          else
            configureFlags;

        env = {
          TCLSH = "${getBin tcl}/bin/tclsh";
        }
        // args.env or { };

        # Run tests after install, at which point we've done all TCLLIBPATH setup
        doCheck = false;
        doInstallCheck = args.doCheck or (args.doInstallCheck or false);
        nativeInstallCheckInputs = args.nativeCheckInputs or [ ] ++ args.nativeInstallCheckInputs or [ ];
        installCheckInputs = args.checkInputs or [ ] ++ args.installCheckInputs or [ ];

        meta = {
          platforms = tcl.meta.platforms;
        }
        // args.meta or { };

      }
      // optionalAttrs (args ? checkPhase) {
        installCheckPhase = args.checkPhase;
      }
    );
}
