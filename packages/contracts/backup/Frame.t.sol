// SPDX-License-Identifier: CC0-1.0
pragma solidity >=0.8.10 <0.9.0;

import "forge-std/Test.sol";
import "../src/Frame.sol";

contract FrameTest is Test {
    Frame private frame;

    address private owner = mkaddr("owner");
    address private minter = mkaddr("minter");

    function mkaddr(string memory name) public returns (address) {
        address addr = address(
            uint160(uint256(keccak256(abi.encodePacked(name))))
        );
        vm.label(addr, name);
        return addr;
    }

    function setUp() public {
        frame = new Frame();
        vm.deal(owner, 10 ether);
        vm.deal(minter, 10 ether);
    }

    function testMint() public {
        assertEq(frame.balanceOf(minter), 0);

        vm.expectRevert(ERC721Base.WrongPayment.selector);
        frame.mint{value: 1 ether}(1);

        vm.prank(minter);
        frame.mint{value: 0.1 ether}(1);
        assertEq(frame.balanceOf(minter), 1);

        vm.prank(minter);
        frame.mint{value: 0.3 ether}(3);
        assertEq(frame.balanceOf(minter), 4);

        vm.prank(minter);
        vm.expectRevert(
            abi.encodeWithSelector(ERC721Base.MintLimitExceeded.selector, 4)
        );
        frame.mint{value: 0.1 ether}(1);
    }
}
