pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract MockERC721 is ERC721, Ownable {
    

    constructor() ERC721("GameItem", "ITM") public {
    }

    function safeMint(address _to, uint _tokenId) public {
        _safeMint(_to, _tokenId);
    }

    
}