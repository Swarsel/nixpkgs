{
  lib,
  stdenv,
  config,
  fetchzip,
  # update script dependencies
  gitUpdater,
  libx11,
  libxau,
  libxcb,
  libxdmcp,
  pkg-config,
  writeText,
  conf ? config.slstatus.conf or null,
  extraLibs ? config.slstatus.extraLibs or [ ],
  patches ? config.slstatus.patches or [ ],
}:

stdenv.mkDerivation (finalAttrs: {
  inherit patches;
  pname = "slstatus";
  version = "1.1";

  src = fetchzip {
    url = "https://dl.suckless.org/tools/slstatus-${finalAttrs.version}.tar.gz";
    hash = "sha256-MRDovZpQsvnLEvsbJNBzprkzQQ4nIs1T9BLT+tSGta8=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    libxcb
    libxau
    libxdmcp
  ]
  ++ extraLibs;

  preBuild =
    let
      configFile =
        if lib.isDerivation conf || builtins.isPath conf then conf else writeText "config.def.h" conf;
    in
    ''
      ${lib.optionalString (conf != null) "cp ${configFile} config.def.h"}
      makeFlagsArray+=(LDLIBS="-lX11 -lxcb -lXau -lXdmcp" CC=$CC)
    '';

  installFlags = [ "PREFIX=$(out)" ];
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Status monitor for window managers that use WM_NAME like dwm";
    homepage = "https://tools.suckless.org/slstatus/";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      qusic
    ];

    platforms = lib.platforms.linux;
    mainProgram = "slstatus";
  };
})
