{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "xcode-install";
  exes = [ "xcversion" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "xcode-install";

  meta = {
    description = "Install and update your Xcodes automatically";
    homepage = "https://github.com/xcpretty/xcode-install";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ q3k ];
    platforms = lib.platforms.unix;
  };
}
