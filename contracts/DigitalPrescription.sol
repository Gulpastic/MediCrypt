// SPDX-License-Identifier: MIT

/**
 * @dev a smart contract that verifies the state of a digital prescription and returns if it is correct and unused via a QR Code.
 *
 * This contract implements the functionality for creating and verifying digital prescriptions.
 *
 * The 'createPrescription' function allows a doctor to create a new prescription by specifying the medicine and the duration of
 * the prescription.
 *
 * The verifyPrescription function allows a patient to verify if a prescription is valid and has not yet been used. The prescription
 * is considered used after it has been verified once.
 *
 * The LogPrescription and LogPrescriptionUsage events are emitted to provide a history of prescription creation and usage for detection so that
 * our frontend can interact with the blockchain
 *
 * @author KartikGP2
 */

pragma solidity ^0.8.0;

contract DigitalPrescription {
    struct Prescription {
        uint256 id;
        address doctor;
        string[] medicine;
        uint256 duration;
        bool usageState;
    }

    /**
     * @dev checks whether the function that is called has been expired or not
     */

    modifier onlyIfNotExpired(uint256 _prescriptionId) {
        require(
            prescriptions[_prescriptionId].duration >= block.timestamp,
            "PRESCRIPTION_HAS_EXPIRED"
        );
        _;
    }

    // mapping between the prescription ID and the struct Prescription
    mapping(uint256 => Prescription) public prescriptions;

    uint256 public nextPrescriptionId;

    event LogPrescription(
        uint256 indexed id,
        address doctor,
        string[] medicine,
        uint256 duration
    );
    event LogPrescriptionUsage(uint256 indexed _id);

    constructor() {
        nextPrescriptionId = 0; // initializes the prescription id to zero
    }

    /**
     * @dev function that creates a new instance of a prescription. This function is only allowed to be called by the doctor (not yet implemented)
     * @param _duration represents the duration of the validity of the prescription
     */

    function createPrescription(string[] memory _medicine, uint256 _duration)
        external
    {
        nextPrescriptionId++;
        prescriptions[nextPrescriptionId].id = nextPrescriptionId;
        prescriptions[nextPrescriptionId].doctor = msg.sender;
        prescriptions[nextPrescriptionId].medicine = _medicine;
        prescriptions[nextPrescriptionId].duration = _duration;
        prescriptions[nextPrescriptionId].usageState = false;
        emit LogPrescription(
            nextPrescriptionId,
            msg.sender,
            _medicine,
            _duration
        );
    }

    /**
     * @dev function verifies the integrity if the digital prescription
     * @return true if the digital prescription has been used
     */

    function verifyPrescription(uint256 _prescriptionId)
        external
        onlyIfNotExpired(_prescriptionId)
        returns (bool)
    {
        if (prescriptions[_prescriptionId].usageState) {
            return false;
        }
        prescriptions[_prescriptionId].usageState = true;
        emit LogPrescriptionUsage(_prescriptionId);
        return true;
    }
}
