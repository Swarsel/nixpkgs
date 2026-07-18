{
  lib,
  bundlerApp,
  bundlerUpdateScript,
  gnugrep,
  libinput,
  makeWrapper,
}:

bundlerApp rec {
  pname = "fusuma";
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram "$out/bin/fusuma" \
      --prefix PATH : ${
        lib.makeBinPath [
          gnugrep
          libinput
        ]
      }
  '';

  exes = [ "fusuma" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript pname;

  meta = {
    description = "Multitouch gestures with libinput driver on X11, Linux";
    homepage = "https://github.com/iberianpig/fusuma";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      nicknovitski
    ];

    platforms = lib.platforms.linux;
  };
}
