{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchpatch,
}:

buildGoModule (finalAttrs: {
  pname = "drive";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "odeke-em";
    repo = "drive";
    rev = "v${finalAttrs.version}";
    hash = "sha256-mNOeOB0Tn5eqULFJZuE18PvLoHtnspv4AElmgEQKXcU=";
  };

  patches = [
    # Add Go Modules support
    (fetchpatch {
      hash = "sha256-4PxsgfufhTfmy/7N5QahIhmRa0rb2eUDXJ66pYb6jFg=";
      url = "https://github.com/odeke-em/drive/commit/0fb4bb2cf83a7293d9a33b00f8fc07e1c8dd8b7c.patch";
    })
  ];

  vendorHash = "sha256-F/ikdr7UCVlNv2yiEemyB7eIkYi3mX+rJvSfX488RFc=";

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "cmd/drive" ];

  meta = {
    description = "Google Drive client for the commandline";
    homepage = "https://github.com/odeke-em/drive";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "drive";
  };
})
