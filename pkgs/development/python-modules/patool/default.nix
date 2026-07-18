{
  lib,
  stdenv,
  fetchFromGitHub,
  argcomplete,
  buildPythonPackage,
  bzip2,
  cabextract,
  diffutils,
  file,
  gnugrep,
  gnutar,
  gzip,
  installShellFiles,
  lzip,
  p7zip,
  pytestCheckHook,
  setuptools,
  unar, # Free alternative to unrar
  xz,
  zip,
  zpaq,
}:

let
  compression-utilities = [
    p7zip
    gnutar
    unar
    cabextract
    zip
    lzip
    zpaq
    gzip
    gnugrep
    diffutils
    bzip2
    file
    xz
  ];
in
buildPythonPackage rec {
  pname = "patool";
  version = "4.0.5";

  #pypi doesn't have test data
  src = fetchFromGitHub {
    owner = "wummel";
    repo = "patool";
    tag = version;
    hash = "sha256-Vo13tbZpMg8tc9LNBqTE+ypEkobU90hbEVq1bI++pUw=";
  };

  postPatch = ''
    substituteInPlace patoolib/util.py \
      --replace-fail 'path = os.environ.get("PATH", os.defpath)' 'path = os.environ.get("PATH", os.defpath) + ":${lib.makeBinPath compression-utilities}"'
  '';

  nativeBuildInputs = [ installShellFiles ];
  nativeCheckInputs = [ pytestCheckHook ] ++ compression-utilities;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd patool \
      --bash <(${argcomplete}/bin/register-python-argcomplete -s bash $out/bin/patool) \
      --fish <(${argcomplete}/bin/register-python-argcomplete -s fish $out/bin/patool) \
      --zsh <(${argcomplete}/bin/register-python-argcomplete -s zsh $out/bin/patool)
  '';

  disabledTests = [
    "test_unzip"
    "test_unzip_file"
    "test_zip"
    "test_zip_file"
    "test_7z"
    "test_7z_file"
    "test_7za_file"
    "test_p7azip"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ "test_ar" ];

  format = "setuptools";

  meta = {
    description = "Portable archive file manager";
    homepage = "https://wummel.github.io/patool/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ marius851000 ];
    mainProgram = "patool";
  };
}
