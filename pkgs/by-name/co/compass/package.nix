{
  lib,
  bundlerEnv,
  bundlerUpdateScript,
  ruby,
}:

bundlerEnv {
  inherit ruby;
  pname = "compass";
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "compass";

  meta = {
    description = "Stylesheet Authoring Environment that makes your website design simpler to implement and easier to maintain";
    homepage = "https://github.com/Compass/compass";
    license = with lib.licenses; mit;

    maintainers = with lib.maintainers; [
      nicknovitski
    ];

    platforms = lib.platforms.unix;
    mainProgram = "compass";
  };
}
