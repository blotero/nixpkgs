{ lib
, angr
, buildPythonPackage
, fetchFromGitHub
, progressbar
, pythonOlder
, tqdm
}:

buildPythonPackage rec {
  pname = "angrop";
  version = "9.0.9166";
  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "angr";
    repo = pname;
    rev = "v${version}";
    sha256 = "1myrzp5axg0dj7kxqc2mz3kfqlds3vzvavcncrj5y9xpx8m7l71m";
  };

  propagatedBuildInputs = [
    angr
    progressbar
    tqdm
  ];

  # Tests have additional requirements, e.g., angr binaries
  # cle is executing the tests with the angr binaries already and is a requirement of angr
  doCheck = false;
  pythonImportsCheck = [ "angrop" ];

  meta = with lib; {
    description = "ROP gadget finder and chain builder";
    homepage = "https://github.com/angr/angrop";
    license = with licenses; [ bsd2 ];
    maintainers = with maintainers; [ fab ];
  };
}
