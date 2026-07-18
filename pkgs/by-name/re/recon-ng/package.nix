{
  lib,
  fetchFromGitHub,
  fetchpatch,
  python3,
  replaceVars,
}:
python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "recon-ng";
  version = "5.1.2";

  src = fetchFromGitHub {
    owner = "lanmaster53";
    repo = "recon-ng";
    tag = "v${finalAttrs.version}";
    hash = "sha256-W7pL4Rl86i881V53SAwECAMp2Qj/azPM3mdvxvt+gjc=";
  };

  patches = [
    # Support python 3.12
    # https://github.com/lanmaster53/recon-ng/pull/218
    # This is merged and can be removed when updating
    (fetchpatch {
      hash = "sha256-e8BTRkwb42mTTwivZ0sTxVw1hnYCUVInmy91jyVc/tw=";
      name = "fix_python12.patch";
      url = "https://github.com/lanmaster53/recon-ng/commit/e31c30e5c314cbc5e57a13f9d3ddf29afafc4cb3.patch";
    })
  ];

  postPatch =
    let
      setup = replaceVars ./setup.py {
        inherit (finalAttrs) pname version;
      };
    in
    ''
      ln -s ${setup} setup.py
    '';

  postInstall = ''
    cp VERSION $out/${python3.sitePackages}/
    cp -R recon/core/web/{definitions.yaml,static,templates} $out/${python3.sitePackages}/recon/core/web/
  '';

  build-system = [
    python3.pkgs.setuptools
  ];

  dependencies = with python3.pkgs; [
    pyyaml
    dnspython
    lxml
    mechanize
    requests
    flask
    flask-restful
    flasgger
    dicttoxml
    xlsxwriter
    unicodecsv
    rq
  ];

  pyproject = true;

  meta = {
    description = "Full-featured framework providing a powerful environment to conduct web-based reconnaissance";
    homepage = "https://github.com/lanmaster53/recon-ng/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ gamedungeon ];
  };
})
