{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "taskjuggler";

  exes = [
    "tj3"
    "tj3client"
    "tj3d"
    "tj3man"
    "tj3ss_receiver"
    "tj3ss_sender"
    "tj3ts_receiver"
    "tj3ts_sender"
    "tj3ts_summary"
    "tj3webd"
  ];

  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "taskjuggler";

  meta = {
    description = "Modern and powerful project management tool";
    homepage = "https://taskjuggler.org/";
    license = lib.licenses.gpl2;

    maintainers = with lib.maintainers; [
      nicknovitski
    ];

    platforms = lib.platforms.unix;
  };
}
