/**
 * @dev solidity smart contract that issues digital prescription object (with the prescription file itself being stored on a decentralized storage) and gives it a verified status.
 *      Only verified doctors are allowed to issue the prescription. After verification the, the patient can access their digital prescription via a progressive web app.
 *      The patient can then take this prescription to a pharmacist (or use it to order medicines online) and the pharmacist can verify that the patient has not forged or tampered
 *      with the prescription. After the patient has used the prescription, the status of the digital prescription is updated and set to 'used' so that it cannot be used again.
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/* errors */
error DigitalPrescription_isExpired(address _user);
error DigitalPrescription_isNotAVerifiedDoctor(address _doctor);
error DigitalPrescription_isNotAVerifiedPharmacist(address _pharmacist);
error DigitalPrescription_alreadyUsed();
error DigitalPrescription_hashNotMatching();
error DigitalPrescription_notTheOwner();

contract DigitalPrescription {
    address _owner;
    struct PrescriptionData {
        bytes32 hash;
        bool used;
        address uploadedBy;
        address verifiedBy;
        uint256 expirationTime;
    }

    /* State Variables */

    mapping(address => PrescriptionData) private prescriptions;
    mapping(address => bool) private verifiedDoctors;
    mapping(address => bool) private verifiedPharmacists;

    /* Events */
    event PrescriptionIssued(address _user, address _doctor, bytes32 _hash);
    event PrescriptionUsed(address _user, address _pharmacist, bytes32 _hash);
    event DoctorStatusChange(address _doctor, bool _status);
    event PharmacistStatusChange(address _pharmacist, bool _status);

    /* modifiers */

    modifier isNotExpired(address _name) {
        if (prescriptions[_name].expirationTime < block.timestamp) {
            revert DigitalPrescription_isExpired(_name);
        }
        _;
    }

    modifier onlyVerifiedDoctors() {
        if (verifiedDoctors[msg.sender]) {
            revert DigitalPrescription_isNotAVerifiedDoctor(msg.sender);
        }
        _;
    }

    modifier onlyVerifiedPharmacists() {
        if (verifiedPharmacists[msg.sender]) {
            revert DigitalPrescription_isNotAVerifiedPharmacist(msg.sender);
        }
        _;
    }

    modifier onlyOwner() {
        if (msg.sender != _owner) {
            revert DigitalPrescription_notTheOwner();
        }
        _;
    }

    constructor() {
        _owner = msg.sender;
    }

    function issuePrescription(
        bytes32 _hash,
        address _user,
        uint256 _expirationTime
    ) external onlyVerifiedDoctors {
        prescriptions[_user].hash = _hash;
        prescriptions[_user].uploadedBy = msg.sender;
        prescriptions[_user].expirationTime = block.timestamp + _expirationTime;
        prescriptions[_user].used = false;
        emit PrescriptionIssued(_user, msg.sender, _hash);
    }

    function verifyPrescriptionAuthenticity(address _user, bytes32 _hash)
        external
        onlyVerifiedPharmacists
    {
        if (prescriptions[_user].used) {
            revert DigitalPrescription_alreadyUsed();
        }
        if (prescriptions[_user].hash == _hash) {
            revert DigitalPrescription_hashNotMatching();
        }
        prescriptions[_user].verifiedBy = msg.sender;
        prescriptions[_user].used = true;
        emit PrescriptionUsed(_user, msg.sender, _hash);
    }

    function changeDoctorStatus(address _doctor, bool _verified) external onlyOwner {
        verifiedDoctors[_doctor] = _verified;
        emit DoctorStatusChange(_doctor, _verified);
    }

    function changePharmacistStatus(address _pharmacist, bool _verified) external onlyOwner {
        verifiedPharmacists[_pharmacist] = _verified;
        emit PharmacistStatusChange(_pharmacist, _verified);
    }

    /* Getter Functions */

    function checkPharmacistStatus(address _pharmacist) external view returns (bool) {
        return verifiedPharmacists[_pharmacist];
    }

    function checkDoctorStatus(address _doctor) external view returns (bool) {
        return verifiedDoctors[_doctor];
    }

    function isPrescriptionUsed(address _user) external view returns (bool) {
        return prescriptions[_user].used;
    }
}
