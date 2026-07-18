{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  nixosTests,
  olm,
  # This option enables the use of an experimental pure-Go implementation of the
  # Olm protocol instead of libolm for end-to-end encryption. Using goolm is not
  # recommended by the mautrix developers, but they are interested in people
  # trying it out in non-production-critical environments and reporting any
  # issues they run into.
  withGoolm ? false,
}:

buildGoModule rec {
  pname = "mautrix-meta";
  version = "26.06";

  src = fetchFromGitHub {
    inherit tag;
    owner = "mautrix";
    repo = "meta";
    hash = "sha256-fpuJc2OAAvOPd/mbkboyx1cwXgMhBYZgILbbBS2R2ko=";
  };

  buildInputs = lib.optional (!withGoolm) olm;
  vendorHash = "sha256-IW+xQbw+YQ5thqyIV5amfUSbOe543meXCNytzHf4p6A=";

  ldflags = [
    "-s"
    "-w"
    "-X"
    "main.Tag=${tag}"
  ];

  subPackages = [ "cmd/mautrix-meta" ];
  tag = "v0.2606.0";
  tags = lib.optional withGoolm "goolm";

  passthru = {
    tests = {
      inherit (nixosTests)
        mautrix-meta-postgres
        mautrix-meta-sqlite
        ;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Matrix-Meta puppeting bridge";
    homepage = "https://github.com/mautrix/meta";
    license = lib.licenses.agpl3Plus;

    maintainers = with lib.maintainers; [
      eyjhb
      sumnerevans
    ];

    mainProgram = "mautrix-meta";
  };
}
