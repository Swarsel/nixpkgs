{
  lib,
  fetchFromGitHub,
  buildGoModule,
  mautrix-gmessages,
  nix-update-script,
  olm,
  testers,
  # This option enables the use of an experimental pure-Go implementation of the
  # Olm protocol instead of libolm for end-to-end encryption. Using goolm is not
  # recommended by the mautrix developers, but they are interested in people
  # trying it out in non-production-critical environments and reporting any
  # issues they run into.
  withGoolm ? false,
}:

buildGoModule rec {
  pname = "mautrix-gmessages";
  version = "26.05";

  src = fetchFromGitHub {
    inherit tag;
    owner = "mautrix";
    repo = "gmessages";
    hash = "sha256-ScsjUmQZsB86hT+EqIoI4V3KX3T1sV9C4/3ytcLV8O0=";
  };

  buildInputs = lib.optional (!withGoolm) olm;
  vendorHash = "sha256-rEcPW/egdx2AhXWqpjpaXbIjbmU9fShOKSv4fUZiX0w=";
  doCheck = true;

  ldflags = [
    "-s"
    "-w"
    "-X"
    "main.Tag=${tag}"
  ];

  tag = "v0.2605.0";
  tags = lib.optional withGoolm "goolm";

  passthru = {
    tests.version = testers.testVersion { package = mautrix-gmessages; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Matrix-Google Messages puppeting bridge";
    homepage = "https://github.com/mautrix/gmessages";
    changelog = "https://github.com/mautrix/gmessages/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ sumnerevans ];
    mainProgram = "mautrix-gmessages";
  };
}
