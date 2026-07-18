{
  lib,
  autoreconfHook,
  stdenvNoCC,
  stdenvNoLibc,
  windows,
  headersOnly ? false,
}:

(if headersOnly then stdenvNoCC else stdenvNoLibc).mkDerivation (
  {
    inherit (windows.mingw_w64_headers)
      version
      src
      ;

    pname = "w32api${lib.optionalString headersOnly "-headers"}";

    outputs = [
      "out"
    ]
    ++ lib.optional (!headersOnly) "dev";

    configureFlags = [ (lib.enableFeature true "w32api") ];
    enableParallelBuilding = true;

    passthru = {
      incdir = "/include/w32api/";
      libdir = "/lib/w32api/";
    };

    meta = {
      inherit (windows.mingw_w64_headers.meta)
        homepage
        downloadPage
        license
        ;

      description = "MinGW w32api package for Cygwin";
      maintainers = [ lib.maintainers.corngood ];
      platforms = lib.platforms.cygwin;
    };
  }
  // (
    if headersOnly then
      {
        preConfigure = ''
          cd mingw-w64-headers
        '';
      }
    else
      {
        nativeBuildInputs = [ autoreconfHook ];

        hardeningDisable = [
          "stackprotector"
          "fortify"
        ];
      }
  )
)
