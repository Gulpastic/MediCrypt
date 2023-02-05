// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract DigitalPrescription {
    address _owner;
    struct PrescriptionData {
        bytes32 hash;
        bool verified;
        address uploadedBy;
    }

    mapping(address => PrescriptionData) prescriptions;
    mapping(address => bool) verifiedDoctors;
    mapping(address => bool) verifiedPharmacists;

    modifier onlyVerifiedDoctors() {
        require(
            verifiedDoctors[msg.sender] == true,
            "Only verified doctors can upload prescriptions"
        );
        _;
    }

    modifier onlyVerifiedPharmacists() {
        require(
            verifiedPharmacists[msg.sender] == true,
            "Only verified pharmacists can verify prescriptions"
        );
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    constructor() {
        _owner = msg.sender;
    }

    function issuePrescription(bytes32 _hash, address _name) external onlyVerifiedDoctors {
        prescriptions[_name].hash = _hash;
        prescriptions[_name].uploadedBy = msg.sender;
    }

    function verifyPrescription(address _user, bytes32 _hash) external onlyVerifiedPharmacists {
        require(prescriptions[_user].hash == _hash, "Prescription hash does not match");
        prescriptions[_user].verified = true;
    }

    function changeDoctorStatus(address _doctor, bool _verified) external onlyOwner {
        verifiedDoctors[_doctor] = _verified;
    }

    function changePharmacistStatus(address _pharmacist, bool _verified) external onlyOwner {
        verifiedPharmacists[_pharmacist] = _verified;
    }

    function isPrescriptionVerified(address _user) external view returns (bool) {
        return prescriptions[_user].verified;
    }
}
