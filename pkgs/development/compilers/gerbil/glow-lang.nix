{
  lib,
  fetchFromGitHub,
  gerbil,
  gerbil-support,
  gerbilPackages,
  ...
}:

rec {
  pname = "glow-lang";
  version = "unstable-2023-12-04";

  postPatch = ''
    substituteInPlace "runtime/glow-path.ss" --replace \
      '(def glow-install-path (source-path "dapps"))' \
      '(def glow-install-path "$out")'
  '';

  postInstall = ''
    mkdir -p $out/bin $out/gerbil/lib/mukn/glow $out/share/glow/dapps
    cp main.ss $out/gerbil/lib/mukn/glow/
    cp dapps/{buy_sig,coin_flip,rps_simple}.glow $out/share/glow/dapps/
    cat > $out/bin/glow <<EOF
    #!/bin/sh
    ORIG_GERBIL_LOADPATH="\$GERBIL_LOADPATH"
    ORIG_GERBIL_PATH="\$GERBIL_PATH"
    ORIG_GERBIL_HOME="\$GERBIL_HOME"
    unset GERBIL_HOME
    GERBIL_LOADPATH="${gerbil-support.gerbilLoadPath ([ "$out" ] ++ gerbilInputs)}"
    GLOW_SOURCE="\''${GLOW_SOURCE:-$out/share/glow}"
    GERBIL_PATH="\$HOME/.cache/glow/gerbil"
    export GERBIL_PATH GERBIL_LOADPATH GLOW_SOURCE ORIG_GERBIL_PATH ORIG_GERBIL_LOADPATH ORIG_GERBIL_HOME
    exec ${gerbil}/bin/gxi $out/gerbil/lib/mukn/glow/main.ss "\$@"
    EOF
    chmod a+x $out/bin/glow
  '';

  gerbil-package = "mukn/glow";

  gerbilInputs = with gerbilPackages; [
    gerbil-utils
    gerbil-crypto
    gerbil-poo
    gerbil-persist
    gerbil-ethereum
    smug-gerbil
    gerbil-leveldb # gerbil-libp2p ftw
  ];

  git-version = "0.3.2-237-g08d849ad";

  pre-src = {
    fun = fetchFromGitHub;
    owner = "Glow-Lang";
    repo = "glow";
    rev = "08d849adef94ae9deead34e6981e77d47806c6e3";
    sha256 = "0dq0s8y3rgx0wa5wsgcdjs0zijnbgff3y4w2mkh5a04gz4lrhl50";
  };

  softwareName = "Glow";
  version-path = "version";

  meta = {
    description = "Glow: language for safe Decentralized Applications (DApps)";
    homepage = "https://glow-lang.org";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fare ];
    platforms = lib.platforms.unix;
    broken = true; # Broken for all platforms since 2023-10-13
  };
}
