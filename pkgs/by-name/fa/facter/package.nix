{
  lib,
  stdenv,
  bundlerApp,
  bundlerUpdateScript,
  coreutils,
  facter,
  gnugrep,
  iproute2,
  makeWrapper,
  net-tools,
  pciutils,
  procps,
  testers,
  util-linux,
  virt-what,
  zfs,
}:

bundlerApp {
  pname = "facter";
  nativeBuildInputs = [ makeWrapper ];

  postBuild =
    let
      runtimeDependencies = [
        coreutils
        gnugrep
        net-tools
        pciutils
        procps
        util-linux
      ]
      ++ lib.optionals stdenv.hostPlatform.isLinux [
        iproute2
        virt-what
        zfs
      ];
    in
    ''
      wrapProgram $out/bin/facter --prefix PATH : ${lib.makeBinPath runtimeDependencies}
    '';

  exes = [ "facter" ];
  gemdir = ./.;

  passthru = {
    tests.version = testers.testVersion {
      version = (import ./gemset.nix).facter.version;
      command = "${lib.getExe facter} --version";
      package = facter;
    };

    updateScript = bundlerUpdateScript "facter";
  };

  meta = {
    description = "System inventory tool";
    homepage = "https://github.com/puppetlabs/facter";
    changelog = "https://www.puppet.com/docs/puppet/latest/release_notes_facter.html";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      womfoo
      anthonyroussel
    ];

    platforms = lib.platforms.unix;
    mainProgram = "facter";
  };
}
