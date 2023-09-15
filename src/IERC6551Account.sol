//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;
/// @dev the ERC-165 identifier for this interface is `0x400a0398`
interface IERC6551Account {
    /// @dev Token bound accounts MUST implement a `receive` function.
    ///
    /// Token bound accounts MAY perform arbitrary logic to restrict conditions
    /// under which Ether can be received.
    receive() external payable;

    /// @dev initialize function is used to initialize the tken bound account
    /// after any ownership change
    ///
    /// The function can only be called by current owner of token
    ///
    /// The function is used to tract current and previous owner of the NFT
    /// which is used during circular locks and to prevent previous owner to call 
    /// the functions of the contract
    ///
    /// @return the status of the call in boolean format
    function initialize() external returns (bool);

    /// @dev the function is used to transfer token during the situations 
    /// of circular lock
    ///
    /// The function first checks the circular lock condition i.e. when 
    /// address(this) equals to the address returned by owner() function
    ///
    /// The function checks if the call is created by previous owner or not
    /// and transfer ownership of token to the previous owner
    ///
    /// @return the status of the call in boolean format
    function unlockCircularLock() external returns (bool);


    /// @dev Executes `call` on address `to`, with value `value` and calldata
    /// `data`.
    ///
    /// MUST revert and bubble up errors if call fails.
    ///
    /// By default, token bound accounts MUST allow the owner of the ERC-721 token
    /// which owns the account to execute arbitrary calls using `executeCall`.
    ///
    /// Token bound accounts MAY implement additional authorization mechanisms
    /// which limit the ability of the ERC-721 token holder to execute calls.
    ///
    /// Token bound accounts MAY implement additional execution functions which
    /// grant execution permissions to other non-owner accounts.
    ///
    /// @return The result of the call
    function executeCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external payable returns (bytes memory);

    /// @dev Returns identifier of the ERC-721 token which owns the
    /// account
    ///
    /// The return value of this function MUST be constant - it MUST NOT change
    /// over time.
    ///
    /// @return chainId The EIP-155 ID of the chain the ERC-721 token exists on
    /// @return tokenContract The contract address of the ERC-721 token
    /// @return tokenId The ID of the ERC-721 token
    function token()
        external
        view
        returns (
            uint256 chainId,
            address tokenContract,
            uint256 tokenId
        );

    /// @dev Returns the owner of the ERC-721 token which controls the account
    /// if the token exists.
    ///
    /// This is value is obtained by calling `ownerOf` on the ERC-721 contract.
    ///
    /// @return Address of the owner of the ERC-721 token which owns the account
    function owner() external view returns (address);

    /// @dev Returns a nonce value that is updated on every successful transaction
    ///
    /// @return The current account nonce
  //  function nonce() external view returns (uint256);
}