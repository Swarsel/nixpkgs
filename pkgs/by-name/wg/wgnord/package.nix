{
  lib,
  fetchFromGitHub,
  bash,
  coreutils,
  curl,
  gnugrep,
  gnused,
  iproute2,
  jq,
  resholve,
  wireguard-tools,
}:

resholve.mkDerivation (finalAttrs: {
  pname = "wgnord";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "phirecc";
    repo = "wgnord";
    rev = finalAttrs.version;
    hash = "sha256-26cfYXtZVQ7kIRxY6oNGCqIjdw/hjwXhVKimVgolLgk=";
  };

  postPatch = ''
    substituteInPlace wgnord \
      --replace '$conf_dir/countries.txt' "$out/share/countries.txt" \
      --replace '$conf_dir/countries_iso31662.txt' "$out/share/countries_iso31662.txt"
  '';

  installPhase = ''
    install -Dm 755 wgnord -t $out/bin/
    install -Dm 644 countries.txt -t $out/share/
    install -Dm 644 countries_iso31662.txt -t $out/share/
  '';

  dontBuild = true;

  solutions.default = {
    execer = [
      "cannot:${iproute2}/bin/ip"
      "cannot:${wireguard-tools}/bin/wg-quick"
    ];

    fix.aliases = true; # curl command in an alias

    inputs = [
      coreutils
      curl
      gnugrep
      gnused
      iproute2
      jq
      wireguard-tools
    ];

    interpreter = "${bash}/bin/sh";
    scripts = [ "bin/wgnord" ];
  };

  meta = {
    description = "NordVPN Wireguard (NordLynx) client in POSIX shell";
    homepage = "https://github.com/phirecc/wgnord";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "wgnord";
  };
})
