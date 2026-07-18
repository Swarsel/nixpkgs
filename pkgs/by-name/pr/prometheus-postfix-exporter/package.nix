{
  lib,
  fetchFromGitHub,
  buildGoModule,
  makeWrapper,
  nixosTests,
  systemdLibs,
  withSystemdSupport ? true,
}:

buildGoModule rec {
  pname = "postfix_exporter";
  version = "0.20.0";

  src = fetchFromGitHub {
    owner = "Hsn723";
    repo = "postfix_exporter";
    tag = "v${version}";
    sha256 = "sha256-tW86lnSLQdyZwvRiqTU1oExZ/zDIrZUraeoAOjs35yY=";
  };

  nativeBuildInputs = lib.optionals withSystemdSupport [ makeWrapper ];
  buildInputs = lib.optionals withSystemdSupport [ systemdLibs ];
  vendorHash = "sha256-T8fTvrpBKm+wDqf+iBeBJh9H1HEebAf0lOnnuF0W5fI=";

  postInstall = lib.optionals withSystemdSupport ''
    wrapProgram $out/bin/postfix_exporter \
      --prefix LD_LIBRARY_PATH : "${lib.getLib systemdLibs}/lib"
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  tags = lib.optionals (!withSystemdSupport) "nosystemd";
  passthru.tests = { inherit (nixosTests.prometheus-exporters) postfix; };

  meta = {
    inherit (src.meta) homepage;
    description = "Prometheus exporter for Postfix";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      globin
    ];

    mainProgram = "postfix_exporter";
  };
}
