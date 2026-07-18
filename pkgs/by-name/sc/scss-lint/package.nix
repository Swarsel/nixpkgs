{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "scss_lint";
  exes = [ "scss-lint" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "scss-lint";

  meta = {
    description = "Tool to help keep your SCSS files clean and readable";
    homepage = "https://github.com/brigade/scss-lint";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      nicknovitski
    ];

    platforms = lib.platforms.unix;
  };
}
