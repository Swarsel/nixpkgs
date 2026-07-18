{
  lib,
  makeBinaryWrapper,
  symlinkJoin,
  testers,
  turbo,
  turbo-unwrapped,
  # https://turbo.build/repo/docs/telemetry
  disableTelemetry ? true,
  disableUpdateNotifier ? true,
}:

symlinkJoin {
  inherit (turbo-unwrapped) version;
  pname = "turbo";
  nativeBuildInputs = [ makeBinaryWrapper ];

  postBuild = ''
    wrapProgram $out/bin/turbo \
      ${lib.optionalString disableTelemetry "--set TURBO_TELEMETRY_DISABLED 1"} \
      ${lib.optionalString disableUpdateNotifier "--set TURBO_NO_UPDATE_NOTIFIER 1"}
  '';

  paths = [ turbo-unwrapped ];

  passthru = {
    tests.version = testers.testVersion { package = turbo; };
  };

  meta = {
    inherit (turbo-unwrapped.meta)
      description
      homepage
      changelog
      license
      mainProgram
      maintainers
      ;
  };
}
