// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.10;

abstract contract OwnerHelper {
    address private owner;

    event OwnerTransferPropose(address indexed _from, address indexed _to);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address _to) onlyOwner public {
        require(_to != owner);
        require(_to != address(0x0));
        owner = _to;
        emit OwnerTransferPropose(owner, _to);
    }
}

abstract contract IssuerHelper is OwnerHelper {
    mapping(address => bool) public issuers;

    event AddIssuer(address indexed _issuer);
    event DelIssuer(address indexed _issuer);

    modifier onlyIssuer {
        require(isIssuer(msg.sender) == true);
        _;
    }

    constructor() {
        issuers[msg.sender] = true;
    }

    function isIssuer(address _addr) public view returns (bool) {
        return issuers[_addr];
    }

    function addIssuer(address _addr) onlyOwner public returns (bool) {
        require(issuers[_addr] == false);
        issuers[_addr] = true;
        emit AddIssuer(_addr);
        return true;
    }

    function delIssuer(address _addr) onlyOwner public returns (bool) {
        require(issuers[_addr] == true);
        issuers[_addr] = false;
        emit DelIssuer(_addr);
        return true;
    }
}

contract CredentialBox is IssuerHelper {
    uint256 private idCount;
    mapping(uint8 => string) private vaccineEnum;

    struct Credential{
        uint256 id; //크리덴셜 생성 인덱스번호
        address issuer; //질병관리청
        uint8 vaccineType; //백신 타입
        uint8 statusNumber; //현재 접종 상태
        string value; //암호화된 접종자의 정보
        uint256 createDate; //크리덴셜 생성일자
    }

    mapping(address => Credential) private credentials;

    constructor() {
        idCount = 1;
        vaccineEnum[0] = "Pfizer";
        vaccineEnum[1] = "Moderna";
        vaccineEnum[2] = "Astrazeneca";
        vaccineEnum[3] = "Janssen";
    }

    //크리덴셜 발급
    function claimCredential(address _alumniAddress, uint8 vaccineType, string calldata _value) onlyIssuer public returns(bool){
        Credential storage credential = credentials[_alumniAddress];
        require(credential.id == 0);
        credential.id = idCount;
        credential.issuer = msg.sender;
        credential.vaccineType = _vaccineType;
        credential.statusNumber = 1;
        credential.value = _value;
        credential.createDate = block.timestamp;

        idCount += 1;

        return true;
    }

    function getCredential(address _vaccineAddress) public view returns (Credential memory){ //크리덴셜 확인
        return credentials[_vaccineAddress];
    }

    function checkCredential(address _alumniAddress) public view returns (bool){ //백신 접종 여부 확인
        if(credentials[_vaccineAddress].statusNumber >=1) return true;
        else return false;
    }

    function addVaccineType(uint8 _type, string calldata _value) onlyIssuer public returns (bool) { //백신 종류 추가
        require(bytes(alumniEnum[_type]).length == 0);
        alumniEnum[_type] = _value;
        return true;
    }

    function getVaccineType(uint8 _type) public view returns (string memory) { //백신 종류 확인
        return vaccineEnum[_vaccineType];
    }

    function changeStatusNumber(address _vaccineAddress) onlyIssuer public returns (bool){ //백신 접종 회차 추가
        require(credentials[_vaccineAddress].statusType >=1); //접종여부 확인 후
        credentials[_vaccineAddress].statusType += 1; //회차 추가
        return true;
    }

}