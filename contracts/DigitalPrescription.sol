// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Prescription {
    address Owner_1 = 0x7Af1F73AA53a2cc820C822457878bcdca247532D;
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
        _owner = Owner_1;
    }

    function uploadPrescription(bytes32 _hash) external onlyVerifiedDoctors {
        prescriptions[msg.sender].hash = _hash;
        prescriptions[msg.sender].uploadedBy = msg.sender;
    }

    function verifyPrescription(address _user, bytes32 _hash) external onlyVerifiedPharmacists {
        require(prescriptions[_user].hash == _hash, "Prescription hash does not match");
        prescriptions[_user].verified = true;
    }

    function changeDoctorStatus(address doctor, bool _verfificationStatus) external onlyOwner {
        require(msg.sender == doctor, "Only the doctor can request verification");
        verifiedDoctors[doctor] = _verfificationStatus;
    }

    function changePharmacistStatus(address _pharmacist, bool _verifiedStatus) external onlyOwner {
        require(msg.sender == _pharmacist, "Only the pharmacist can request verification");
        verifiedPharmacists[_pharmacist] = _verifiedStatus;
    }

    function isPrescriptionVerified(address user) public view returns (bool) {
        return prescriptions[user].verified;
    }
}
