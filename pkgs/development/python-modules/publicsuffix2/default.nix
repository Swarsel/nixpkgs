{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  publicsuffix-list,
  setuptools,
}:
let
  tagVersion = "2.2019-12-21";
in
buildPythonPackage {
  pname = "publicsuffix2";
  # tags have dashes, while the library version does not
  # see https://github.com/nexB/python-publicsuffix2/issues/12
  version = lib.replaceStrings [ "-" ] [ "" ] tagVersion;

  src = fetchFromGitHub {
    owner = "nexB";
    repo = "python-publicsuffix2";
    rev = "release-${tagVersion}";
    hash = "sha256-OV0O4LLxQ2LQiEHc1JTvScu35o2IWxo/hgn/COh2e7Y=";
  };

  postPatch = ''
    # only used to update the interal publicsuffix list
    substituteInPlace setup.py \
      --replace "'requests >= 2.7.0'," ""

    rm src/publicsuffix2/public_suffix_list.dat
    ln -s ${publicsuffix-list}/share/publicsuffix/public_suffix_list.dat src/publicsuffix2/public_suffix_list.dat
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "publicsuffix2" ];

  meta = {
    description = "Get a public suffix for a domain name using the Public Suffix List";
    homepage = "https://github.com/nexB/python-publicsuffix2";
    license = lib.licenses.mpl20;
    maintainers = [ ];
  };
}
