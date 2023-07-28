// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract BabysharkUniverseToken is ERC20, Pausable, AccessControlEnumerable {
    event TokensBurned(address request, uint256 amount); 
    
    bytes32 private constant OWNER_ROLE = keccak256("OWNER_ROLE");

    constructor() ERC20("Baby Shark Universe Token", "BSU") {

        _setupRole(OWNER_ROLE, msg.sender);
        _setRoleAdmin(OWNER_ROLE, OWNER_ROLE);        

        _mint(msg.sender, 1500000000 * 10**uint(decimals()));
    }

    function distributeTokens(
        address[] memory recipients,
        uint256[] memory amounts
    ) external onlyOwner {
        require(
            recipients.length == amounts.length,
            "Recipients and amounts arrays must have the same length"
        );

        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Recipient address must not be a zero address");
            _transfer(msg.sender, recipients[i], amounts[i]);
        }
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal whenNotPaused override {
        super._beforeTokenTransfer(from, to, amount);
    }

    function burn(uint256 _amount) external onlyOwner returns (bool) {
        require(_amount > 0, "Amount must be greater than 0");

        _burn(msg.sender, _amount);
        emit TokensBurned(msg.sender, _amount);
        return true;
    }

    modifier onlyOwner() {
        require(
            hasRole(OWNER_ROLE, msg.sender),
            "caller is not an owner"
        );
        _;
    }

    function addOwner(address newOwner) public onlyOwner {
        grantRole(OWNER_ROLE, newOwner);
    }

    function removeOwner(address owner) public onlyOwner {
        revokeRole(OWNER_ROLE, owner);
    }

    function getOwners() public view returns (address[] memory) {
        uint256 count = getRoleMemberCount(OWNER_ROLE);
        address[] memory owners = new address[](count);

        for (uint256 i = 0; i < count; i++) {
            owners[i] = getRoleMember(OWNER_ROLE, i);
        }

        return owners;
    }
}