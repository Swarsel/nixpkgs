{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "godef";
  version = "1.1.2";

  src = fetchFromGitHub {
    inherit rev;
    owner = "rogpeppe";
    repo = "godef";
    sha256 = "0rhhg73kzai6qzhw31yxw3nhpsijn849qai2v9am955svmnckvf4";
  };

  vendorHash = null;
  doCheck = false;
  rev = "v${version}";
  subPackages = [ "." ];

  meta = {
    description = "Print where symbols are defined in Go source code";
    homepage = "https://github.com/rogpeppe/godef/";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      vdemeester
      rvolosatovs
    ];

    mainProgram = "godef";
  };
}
