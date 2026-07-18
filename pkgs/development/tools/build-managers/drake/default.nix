{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "drake";
  exes = [ "drake" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "drake";

  meta = {
    description = "Branch of Rake supporting automatic parallelizing of tasks";
    homepage = "http://quix.github.io/rake/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      romildo
      nicknovitski
    ];

    platforms = lib.platforms.unix;
  };
}
