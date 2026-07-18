{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "fpm";
  exes = [ "fpm" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "fpm";

  meta = {
    description = "Tool to build packages for multiple platforms with ease";
    homepage = "https://github.com/jordansissel/fpm";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      nicknovitski
    ];

    platforms = lib.platforms.unix;
    mainProgram = "fpm";
  };
}
