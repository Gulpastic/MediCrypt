// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./DigitalPrescription.sol";
import "./VerifyAddress.sol";

contract DrugSupply is DigitalPrescription, VerifyAddress {
    struct DrugInfo {
        string name;
        bytes32 hash;
        address supplier;
        address distributor;
        address retailer;
        uint256 dateAdded;
    }

    mapping(uint256 => DrugInfo) public drugs;

    // Create a mapping to store the role of each address
    mapping(address => bool) public isPharmacist;

    event LogDrugSupplyChange(string name, bytes32 hash, uint256 dateAdded);

    // Function to add a new drug to the supply
    function addDrug(
        string memory _name,
        bytes32 _hash,
        uint256 _drugId,
        address _supplier,
        address _distributor,
        address _retailer
    ) external onlyVerifiedPharmacists {
        drugs[_drugId] = DrugInfo(
            _name,
            _hash,
            _supplier,
            _distributor,
            _retailer,
            block.timestamp
        );
        emit LogDrugSupplyChange(_name, _hash, block.timestamp);
    }

    // Function to update the quantity of a drug
    // function updateDrugQuantity(uint256 _drugId) external onlyVerifiedPharmacists {
    //     drugs[_drugId].quantity = _quantity;
    //     emit LogDrugSupplyChange(_drugId, _quantity);
    // }

    // Function to retrieve information about a specific drug

    function getDrug(uint256 _drugId) external view onlyOwner returns (string memory, bytes32) {
        DrugInfo storage drug = drugs[_drugId];
        return (drug.name, drug.hash);
    }

    // Function to assign the role of pharmacist to an address
    function assignPharmacistRole(address _address) external onlyOwner {
        isPharmacist[_address] = true;
    }

    // Function to revoke the role of pharmacist from an address
    function revokePharmacistRole(address _address) external onlyOwner {
        isPharmacist[_address] = false;
    }
}
