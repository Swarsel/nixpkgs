{
  lib,
  stdenv,
  fetchFromGitLab,
  buildPythonPackage,
  libvirt,
  lxml,
  pkg-config,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "libvirt";
  version = "12.4.0";

  src = fetchFromGitLab {
    owner = "libvirt";
    repo = "libvirt-python";
    tag = "v${version}";
    hash = "sha256-8+o3ji7b0PCGxnHbsUJTUn1oudeN3rV+ehUILmufD1M=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail 'pkg-config' "${stdenv.cc.targetPrefix}pkg-config"
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libvirt
    lxml
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "libvirt" ];

  meta = {
    description = "Libvirt Python bindings";
    homepage = "https://libvirt.org/python.html";
    license = lib.licenses.lgpl2;
    maintainers = [ lib.maintainers.fpletz ];
  };
}
