// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./DigitalPrescription.sol";

contract VerifyAddress is DigitalPrescription {
    // Events
    event NewSupplier(address _supplier);
    event NewDistributor(address _distributor);
    event NewRetailer(address _retailer);

    mapping(address => bool) public verifiedAddress;

    // Functions
    function setSupplier(address _supplier, bool _status) external onlyOwner {
        verifiedAddress[_supplier] = _status;
        emit NewSupplier(_supplier);
    }

    function setDistributor(address _distributor, bool _status) external onlyOwner {
        verifiedAddress[_distributor] = _status;
        emit NewDistributor(_distributor);
    }

    function setRetailer(address _retailer, bool _status) public {
        verifiedAddress[_retailer] = _status;
        emit NewRetailer(_retailer);
    }
}
