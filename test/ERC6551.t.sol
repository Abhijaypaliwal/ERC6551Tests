// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/erc6551.sol";
import "../src/IERC6551Account.sol";
import "../src/ERC6551Registry.sol";
import "../src/basicERC721.sol";
import "../lib/forge-std/src/console.sol";

contract AccountTest is Test {
    ERC6551Registry public registry;
    ExampleERC6551Account public implementation;
    MockERC721 nft = new MockERC721();

    function setUp() public {
        registry = new ERC6551Registry();
        implementation = new ExampleERC6551Account();
    }

    function testDeploy() public {
        address deployedAccount = registry.createAccount(
            address(implementation),
            block.chainid,
            address(0),
            0,
            0,
            ""
        );

        assertTrue(deployedAccount != address(0));

        address predictedAccount = registry.account(
            address(implementation),
            block.chainid,
            address(0),
            0,
            0
        );

        assertEq(predictedAccount, deployedAccount);
    }

    // function testCall() public {
    //     nft.mint(vm.addr(1), 1);

    //     address account = registry.createAccount(
    //         address(implementation),
    //         block.chainid,
    //         address(nft),
    //         1,
    //         0,
    //         ""
    //     );

    //     assertTrue(account != address(0));

    //    // IERC6551Account accountInstance = IERC6551Account(payable(account));
    //    IERC6551Account accountInstance = IERC6551Account(payable(account));
    //    // IERC6551Executable executableAccountInstance = IERC6551Executable(account);

    //     assertEq(
    //         accountInstance.isValidSigner(vm.addr(1), ""),
    //         IERC6551Account.isValidSigner.selector
    //     );

    //     vm.deal(account, 1 ether);

    //     vm.prank(vm.addr(1));
    //     executableAccountInstance.execute(payable(vm.addr(2)), 0.5 ether, "", 0);

    //     assertEq(account.balance, 0.5 ether);
    //     assertEq(vm.addr(2).balance, 0.5 ether);
    //     assertEq(accountInstance.state(), 1);
    // }

    function testCircularLock() public {
        nft.safeMint(vm.addr(1), 1);
        console.log(msg.sender);
        console.log("old owner of token is", nft.ownerOf(1));
        address account = registry.createAccount(
            address(implementation),
            block.chainid,
            address(nft),
            1,
            0,
            ""
        );
        vm.prank(vm.addr(1));
        IERC6551Account accountInstance = IERC6551Account(payable(account));
        nft.transferFrom(vm.addr(1), vm.addr(2), 1);
        console.log("new owner of token is", nft.ownerOf(1));

        vm.prank(vm.addr(2));
        accountInstance.initialize();
        nft.safeMint(vm.addr(1), 2);
        vm.prank(vm.addr(1));

        nft.transferFrom(vm.addr(1), address(accountInstance), 2);
        console.log("owner of token 2 is", nft.ownerOf(2));

        //@dev transferring token of TBA to its own wallet 
        // which is circular lock condition
        vm.prank(vm.addr(2));
        nft.transferFrom(vm.addr(2),address(accountInstance), 1);
        assertEq(address(accountInstance), nft.ownerOf(1));

        //@dev recovering the token from its own wallet
        vm.prank(vm.addr(2));
        accountInstance.unlockCircularLock();
        assertEq(vm.addr(2), nft.ownerOf(1));

        
        

    }

    function testFailedCircularLock() external {

        nft.safeMint(vm.addr(2), 1);
        console.log(msg.sender);
        console.log("old owner of token is", nft.ownerOf(1));
        address account = registry.createAccount(
            address(implementation),
            block.chainid,
            address(nft),
            1,
            0,
            ""
        );
        
        IERC6551Account accountInstance = IERC6551Account(payable(account));

        //@dev testing failed circularLock condition
        // here owner transfers NFT to address 1
        // address 1 would not call initialize
        // and address 2 transfers NFT to address 3

        vm.prank(vm.addr(2));
        nft.transferFrom(vm.addr(2), vm.addr(3), 1);
        console.log("owner of NFT after transfer from account 2  is", nft.ownerOf(1));

        // @notice address 3 not calls initialize function
        // now address 4 transfers NFT to another address

        vm.prank(vm.addr(3));
        nft.transferFrom(vm.addr(3), vm.addr(4), 1);
        console.log("owner of NFT after transfer from account 3 is", nft.ownerOf(1));

        //@note that now address 4 calls initialize function

        vm.startPrank(vm.addr(4));
        accountInstance.initialize();

        //@dev now following circular lock
        nft.transferFrom(vm.addr(4),address(accountInstance), 1);
        console.log("owner of NFT after transfer with circular lock is", nft.ownerOf(1));

        //@dev now checking error when previous owner calls recover circular lock
        //vm.prank(vm.addr(4));
        vm.expectRevert();
        accountInstance.unlockCircularLock();

    }
}
