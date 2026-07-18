{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "riemann-dash";
  exes = [ "riemann-dash" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "riemann-dash";

  meta = {
    description = "Javascript, websockets-powered dashboard for Riemann";
    homepage = "https://github.com/riemann/riemann-dash";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      nicknovitski
    ];

    platforms = lib.platforms.unix;
  };
}
